import ssl
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)

# Configura o CORS para permitir todas as origens e credenciais
CORS(app, supports_credentials=True)

@app.route('/')
def index():
    return "Hello World!"

def runFlaskport(app, debug, host, port):
    # Caminho para o certificado SSL e a chave privada
    ssl_cert = 'ssl/nginx-ssl.crt'
    ssl_key = 'ssl/nginx-ssl.key'
    
    # Configurações de contexto SSL
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS)
    ssl_context.load_cert_chain(ssl_cert, ssl_key)
    
    app.run(ssl_context=ssl_context, debug=debug, host=host, port=port)

if __name__ == '__main__':
    runFlaskport(app, False, '0.0.0.0', 8000)