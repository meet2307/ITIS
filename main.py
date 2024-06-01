from flask import Flask, jsonify, request, send_from_directory, send_file, url_for, g
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from flask_mail import Mail, Message
from itsdangerous import URLSafeTimedSerializer as Serializer
import os
import base64
import time
import random
import string
import io

reset_username=""

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'verysecretkey'
app.config['MAIL_SERVER'] = 'smtp.googlemail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
app.config['MAIL_USERNAME'] = 'rmitlibrary4@gmail.com'
app.config['MAIL_PASSWORD'] = 'sdqv cmzf nozr aucz'
app.config['MAIL_DEFAULT_SENDER'] = 'rmitlibrary4@gmail.com'
DEBUG = True
ENV = 'development'  # or 'production'
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
CORS(app, resources={r"/*": {"origins": "*"}})
mail = Mail(app)

class User(db.Model):
    # id = db.Column(db.Integer, primary_key=True)
    # email=db.Column(db.String(80), unique=True, nullable=False)
    # username = db.Column(db.String(80), unique=True, nullable=False)
    # password = db.Column(db.String(100), nullable=False)
    # role = db.Column(db.String(20), default='user')
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(80), unique=True, nullable=False)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(20), default='user')
    reset_token = db.Column(db.String(200), nullable=True)
    reset_token_validated = db.Column(db.Boolean, default=False)
    two_fa_code = db.Column(db.String(6), nullable=True)

    def get_reset_password_token(self, expires_sec='1800'):
        print("REACHED")
        global s;
        s=Serializer(app.config['SECRET_KEY'].encode('utf-8'), expires_sec)
        print("Generated token:", s.dumps({'user_id': self.id}))
        token = s.dumps({'user_id': self.id})
        self.reset_token = token
        self.reset_token_validated = False
        db.session.commit()
        return token
        #return s.dumps({'user_id': self.id})

    @staticmethod
    def verify_reset_password_token(token):
        # s = Serializer(app.config['SECRET_KEY'].encode('utf-8'))
        print("Validate S:",s)
        try:
            user_id = s.loads(token, max_age=1800)['user_id']
            print("Decoded user_id:", user_id)
        except Exception as e:
            print("Token error:", str(e))
            return None
        return User.query.get(user_id)

class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    #filepath = db.Column(db.String(200), nullable=False)
    data = db.Column(db.LargeBinary, nullable=False)
    mimetype = db.Column(db.String(50), nullable=False)



@app.route('/reset_password_request', methods=['POST'])
def reset_password_request():
    print("START")
    data = request.json
    print("GOT DATA")
    user = User.query.filter_by(email=data['email']).first()
    print("User is:",user)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    token = user.get_reset_password_token()
    print("BACK")
    print(token)
    msg = Message('Reset Your Password',
                  recipients=[user.email],
                  body=f"To reset your password, visit the following link: {url_for('validate_token', token=token, _external=True)}\nIf you did not make this request then simply ignore this email and no changes will be made.")
    mail.send(msg)

    timeout = 600  # 10 minutes timeout
    start_time = time.time()

    while time.time() - start_time < timeout:
        db.session.refresh(user)  # Refresh user data from the database
        if user.reset_token_validated:
            return jsonify({
                               'message': 'If an account with that email exists, a reset link has been sent and token is valid.'}), 200
        time.sleep(5)  # Sleep for 5 seconds before checking again

    return jsonify({'message': 'If an account with that email exists, a reset link has been sent.'}), 200

@app.route('/validate_token/<token>', methods=['GET'])
def validate_token(token):
    print("Validated token:",token)
    user = User.verify_reset_password_token(token)
    print("Validate user:",user)
    # if user:
    #     g.validate_response= 200
    #     print("Validate response is:",g.validate_response)
    #     return jsonify({'message': 'Token is successfully validated'}), 200
    # g.validate_response=400
    if user and user.reset_token == token:
        user.reset_token_validated = True
        db.session.commit()
        return jsonify({'message': 'Token is successfully validated'}), 200
    return jsonify({"message": "Invalid or expired token"}), 400

# @app.route('/validate_response', methods=['POST'])
# def get_validate_response():
#     print("Ready to change password")
#     if g.validate_response==200:
#         return jsonify({'message': 'Token is successfully validated'}), 200
#     return jsonify({"message": "Invalid or expired token"}), 400


@app.route('/reset_password', methods=['GET', 'POST'])
def reset_password():
    if request.method == 'POST':
        data = request.json
        user = User.query.filter_by(email=data['email']).first()
        user.password = bcrypt.generate_password_hash(data['new_password'])
        db.session.commit()
        return jsonify({'message': 'Your password has been updated.'}), 200
    # If GET request, you might want to show a password reset form if it's web-based or handle differently in API
    return jsonify({'message': 'A problem occured while updating the password!'}), 400  # Assuming there's a frontend route for setting new password


@app.route('/register', methods=['POST'])
def register():
    data = request.json
    hashed_password = bcrypt.generate_password_hash(data['password']).decode('utf-8')
    user = User(username=data['username'], password=hashed_password, role=data.get('role', 'user'),email=data['email'])
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": "User registered successfully"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(username=data['username']).first()
    if user and bcrypt.check_password_hash(user.password, data['password']) and user.role==data['role']:

        user.two_fa_code = ''.join(random.choices(string.digits, k=6))
        db.session.commit()
        msg = Message('Your 2FA Code', recipients=[user.email])
        msg.body = f'Your 2FA code is {user.two_fa_code}'
        mail.send(msg)

        return jsonify({"message": "Login successful", "role": user.role}), 200
    return jsonify({"error": "Invalid credentials"}), 401

@app.route('/verify_2fa', methods=['POST'])
def verify_2fa():
    data = request.get_json()
    user = User.query.filter_by(username=data['username']).first()

    if user and user.two_fa_code == data['code']:
        user.two_fa_code = None  # Clear the 2FA code once it has been used
        db.session.commit()
        return jsonify({'message': '2FA verification successful'}), 200

    return jsonify({'message': 'Invalid 2FA code'}), 401

@app.route('/books', methods=['GET'])
def list_books():
    books = Book.query.all()
    return jsonify({'books': [{ 'id': book.id, 'title': book.title } for book in books]}), 200

# @app.route('/download/<int:book_id>', methods=['GET'])
# def download_book(book_id):
#     book = Book.query.get(book_id)
#     if book:
#         return send_from_directory(os.path.abspath(os.path.dirname(__file__)), book.filepath, as_attachment=True)
#     return jsonify({"error": "Book not found"}), 404
@app.route('/add_book', methods=['POST'])
def insert_book():
    print("READY TO INSERT")
    data = request.json
    title=data['title']
    file_data = base64.b64decode(data['file_data'])
    # with open(file_path, 'rb') as file:
    #     file_data = file.read()
    mimetype = 'application/pdf'
    new_book = Book(title=title, data=file_data, mimetype=mimetype)
    db.session.add(new_book)
    db.session.commit()
    return jsonify({"message": "Upload successful"}), 200

@app.route('/delete_book/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    try:
        book = Book.query.get(book_id)
        if not book:
            return jsonify({'message': 'Book not found'}), 404

        db.session.delete(book)
        db.session.commit()
        return jsonify({'message': 'Book deleted successfully'}), 200
    except Exception as e:
        print(f'Error occurred: {e}')
        return jsonify({'message': f'Failed to delete book: {e}'}), 500

@app.route('/download/<int:book_id>', methods=['GET'])
def download_book(book_id):
    print("BOOK ACCESS")
    book = Book.query.get(book_id)
    if book:
        print("BOOK FOUND")
        print("BOOK_ID:",book.id)
        print("BOOK_TITLE:", book.title)
        print("BOOK_DATA:", book.data)
        print("BOOK_MIME:", book.mimetype)
        file_response=send_file(
            io.BytesIO(book.data),
            mimetype=book.mimetype,
            as_attachment=True,
            download_name=f"{book.title}.pdf"
        )
        print("FILE:",file_response)
        return file_response
    return jsonify({"error": "Book not found"}), 404


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
