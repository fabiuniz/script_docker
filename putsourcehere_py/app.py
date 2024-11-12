#mestre de serimonia
#ambientação 
#conteudo anuncia passos contestualizado ferramenta
#Fundo do posso
#Auge
from lib_func import *

app = Flask(__name__, template_folder="templates")

# CORS(app, resources={r"/process/*": {"origins": ["http://localhost:9257", "https://another-domain.com"]}})
CORS(app, supports_credentials=True)  # Isso permite CORS para todas as rotas do seu aplicativo

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/index2")
def index2():
    return render_template("index2.html")

@app.route("/index3")
def index3():
    return render_template("index3.html")

# Rota para fornecer os dados JSON
@app.route("/data")
def get_data():
    with open('data/data.json') as json_file:
        data = json.load(json_file)
    return jsonify(data)

# Rota para fornecer os dados JSON
@app.route("/extraipdfs", methods=["GET", "POST"]) 
def process_pdfs_in_directory():
    directory = 'uploads/'
    data = {"ret": "PDFs processados com sucesso."}      
    for filename in os.listdir(directory):
        if filename.endswith('.pdf'):
            pdf_path = os.path.join(directory, filename)
            text = extract_text_from_pdf(pdf_path)
            if text == "":
                text = extract_text_from_pdf_with_ocr(pdf_path)
            data[filename] = text
            structured_data = extract_structured_data(text)            
            # Salva o JSON na mesma pasta
            json_filename = f"{os.path.splitext(filename)[0]}.json"
            json_path = os.path.join(directory, json_filename)
            with open(json_path, 'w', encoding='utf-8') as json_file:
                json.dump(structured_data, json_file, ensure_ascii=False, indent=4)            
            print(f"Processed {filename} and saved to {json_filename}")
    # Retorna uma resposta    
    return jsonify(data)

# Rota para processar a solicitação GET
@app.route("/process", methods=["GET", "POST"])
def processar_get():
    data = request.get_json()  # Obtém o JSON dos dados enviados no corpo da solicitação
    data["teste"] = "novo item"
    return jsonify({"mensagem": "JSON recebido com sucesso!", "dados": data})

# Rota
@app.route("/processb", methods=["GET", "POST"])
def processar_getb():
    return "GET recebido com sucesso b!"

# Rota
@app.route("/makexlsx", methods=["GET", "POST"])
def processar_makexlsx():
    # Carregue o JSON
    json_data = '''
        [
            {
                "Nome": "Alice",
                "Idade": 30
            },
            {
                "Nome": "Bob",
                "Idade": 25
            }
        ]
        '''    
    filename="uploads/doc3.xlsx"
    #data = json.loads(json_data)
    jscfg ="static/js/cfg_js.js"
    objson = processar_teste("dadosjson",jscfg)
    data = objson["retor"]["reports"]
    xlsx_processor = cls_xlsx(data)    
    return xlsx_processor.inserir_xlsx(filename,jscfg,data,"VARIAVEISPJE")

# Rota
@app.route("/xlsx", methods=["GET", "POST"])
def proc_xlsx():
    dados_json = request.get_json()    
    origem ="uploads/doc3.xlsx"
    filename = dados_json['retor']['reports']['Pje_Calc_Calculo_Dados_do_Calculo_Nome_formulario_reclamanteNome']
    filename = "dt_" +filename.replace(" ", "_").lower()
    destino ="uploads/"+filename+".xlsx"
    xlsx_processor = cls_xlsx(dados_json)    
    return xlsx_processor.replace_xlsx(origem,destino,"RESUMO")    

# Rota
@app.route("/teste", methods=["GET", "POST"])
def processar_test():    
    js_runner = cls_js("static/js/cfg_js.js")  # Crie uma instância de cls_js com o arquivo JavaScript
    resultado = js_runner.getvar_js('dados')  # Acesse a variável JavaScript "dados"
    return resultado

# Rota
@app.route("/PDF2TCURL/<sender>/<called>", methods=["GET", "POST"])#http://localhost:5000/PDF2TCURL/passprm/passprm?teste=1
def processar_pdftotextcurl(sender,called):
    #Act
    #sender
    #called
    #print(request.get_json())
    print(sender,called)
    print(request.args.get("teste"))
    js_runner = cls_js("static/js/cfg_js.js")  # Crie uma instância de cls_js com o arquivo JavaScript
    resultado = js_runner.getvar_js('pdfxtruct')  # Acesse a variável JavaScript "dados"
    resultado["ret"]=exppdf('extracteste.pdf')    
    resultado= json.dumps(resultado,indent=4 )
    return json.loads(resultado)

# Rota #https://ctrlproc.newcap.com.br/ctrlphp/testes/teste.php
@app.route('/upload', methods=['POST'])
def upload_file():
    try:
        file = request.files['file']
        # Obtém o nome do arquivo
        filename = file.filename
        # Define a subpasta onde os arquivos serão salvos
        upload_folder = 'uploads'        
        # Cria a subpasta se ela não existir
        os.makedirs(upload_folder, exist_ok=True)        
        # Caminho completo para salvar o arquivo
        filepath = os.path.join(upload_folder, filename)        
        # Recebe os dados binários do arquivo no corpo da requisição
        file_content = file.read()                
        # Salva os dados em um arquivo na subpasta
        with open(filepath, 'wb') as file:
            file.write(file_content)        
        return jsonify({'message': 'Arquivo recebido e salvo com sucesso.', 'success': True})
    except Exception as e:
        return jsonify({'message': f'Erro ao receber o arquivo: {str(e)}', 'success': False})

def runFlaskport(app,db,ht,pt):
     # Caminho para o certificado SSL e a chave privada
    ssl_cert = 'ssl/nginx-ssl.crt'
    ssl_key = 'ssl/nginx-ssl.key'
    # Configurações de contexto SSL
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS)
    ssl_context.load_cert_chain(ssl_cert, ssl_key)
    app.run(ssl_context=ssl_context,debug=db, host=ht,port=pt)

def extract_structured_data(text):
    data = {}
    # Expressões regulares com grupos de captura
    data['processo'] = extract_match(r'PROCESSO\s*:\s*([\d\.\-]+)', text)
    data['vara'] = extract_match(r'VARA\s*:\s*(.+)', text)
    data['reclamada'] = extract_match(r'RECLAMADA\s*:\s*(.+)', text)
    data['reclamante'] = extract_match(r'RECLAMANTE\s*:\s*(.+)', text)
    data['admissao'] = extract_match(r'ADMISSÃO\s*:\s*([\d\/]+)', text)
    data['demissao'] = extract_match(r'DEMISSÃO\s*:\s*([\d\/]+)', text)
    data['inicio_calculo'] = extract_match(r'INÍCIO CÁLCULO\s*:\s*([\d\/]+)', text)
    data['fim_calculo'] = extract_match(r'FIM DE CÁLCULO\s*:\s*([\d\/]+)', text)
    data['dt_ajuizamento'] = extract_match(r'DT. AJUIZAMENTO\s*:\s*([\d\/]+)', text)
    data['dt_atualizacao'] = extract_match(r'DT. ATUALIZAÇÃO\s*:\s*([\d\/]+)', text)
    data['dt_calculo'] = extract_match(r'DT. DE CÁLCULO\s*:\s*([\d\/]+)', text)
    data['local'] = extract_match(r'(RIO DE JANEIRO\/RJ|SÃO PAULO\/SP|CURITIBA\/PR)', text)
    data['credito_bruto_sem_juros'] = extract_match(r'Crédito Bruto do Recte em [\d\/]+ sem Juros\s*:\s*R\$\s*([\d\.,]+)', text)
    data['juros'] = extract_match(r'Juros a partir de [\d\/]+\s*:\s*R\$\s*([\d\.,]+)', text)
    data['credito_bruto_com_juros'] = extract_match(r'Crédito Bruto c\/Juros do Recte em [\d\/]+\s*:\s*R\$\s*([\d\.,]+)', text)
    data['inss_reclamante'] = extract_match(r'INSS cota Reclamante\s*:\s*R\$\s*([\d\.,]+)', text)
    data['irrf'] = extract_match(r'IRRF\s*:\s*(.+)', text)
    data['total_liquido_reclamante'] = extract_match(r'Total Líquido do Reclamante\s*:\s*R\$\s*([\d\.,]+)', text)
    data['honorarios_sucumbencia'] = extract_match(r'Hon. Sucumb. sobre Crédito Bruto \(10,00%\) a cargo da Reclamada R\$\s*([\d\.,]+)', text)
    data['inss_reclamada'] = extract_match(r'Total INSS cota Reclamada 25,50 %\s*:\s*R\$\s*([\d\.,]+)', text)
    data['total_geral_execucao'] = extract_match(r'Total Geral da Execução\s*:\s*R\$\s*([\d\.,]+)', text)   
    # Capturar observações
    obs_match = re.search(r'OBSERVAÇÕES\s*:\s*(.+)', text, re.DOTALL)
    if obs_match:
        data['observacoes'] = obs_match.group(1).strip()
    else:
        data['observacoes'] = "Não há observações."
    return data

def extract_match(pattern, text):
    """Retorna a correspondência de regex ou uma string vazia se não houver correspondência."""
    match = re.search(pattern, text)
    return match.group(1) if match and match.lastindex >= 1 else ""

def extract_text_from_pdf_with_ocr(pdf_path):
    # Abre o PDF
    pdf_document = fitz.open(pdf_path)
    # Variável para armazenar o texto extraído
    extracted_text = "Nada"
    # Verifica se o PDF contém imagens
    for page_number in range(len(pdf_document)):
        page = pdf_document.load_page(page_number)
        images = page.get_images(full=True)
        if images:
            # Se imagens forem encontradas, usa OCR
            print(f"Página {page_number + 1} contém imagens. Aplicando OCR...")
            # Converte a página PDF para imagem
            pil_images = convert_from_path(pdf_path, first_page=page_number + 1, last_page=page_number + 1)
            for image in pil_images:
                extracted_text += pytesseract.image_to_string(image)
        else:
            # Se não houver imagens, extrai o texto diretamente
            extracted_text += page.get_text()
    return extracted_text

if __name__ == "__main__":   
    makerdirs()
    distribuir()
 
    #embed_files("prepjobpy","uploads","doc3.xlsx")

    #Inicia seviço e abre browser
    #from lib_browser import *
    #runServerAndBrowser(app,'http://localhost:5000/',"5000")

    # Abre o navegador padrão com a URL local
    #webbrowser.open("http://localhost:5000")   


    # Inicia o servidor Flask na porta 5000 em uma thread
    server_thread = ServerThread(runFlaskport, args=(app,False,'0.0.0.0',8000,))
    # Inicie a execução da thread
    server_thread.start()

    # Inicia o servidor Flask na porta 5000
    # app.run(port=5000)  # debug=True

    # grava Logs
    # utils = cls_utils("teste.log")
    # logger = utils.definelogs()    
    # #utils.setstdout()
    # logger.info("teste")
    