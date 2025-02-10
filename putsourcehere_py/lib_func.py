
import threading,openpyxl,os,pkgutil,execjs,pkg_resources, logging,sys,subprocess,base64,openpyxl, webbrowser,pandas,fitz, ssl, re,pytesseract,io
from flask import Flask, jsonify, request, json, render_template,jsonify,json
from flask_cors import CORS
from pypdf import PdfReader
from datetime import datetime, timedelta
from pprint import pprint
from PIL import Image

# Crie uma classe que herde de threading.Thread
class ServerThread(threading.Thread):
    def __init__(self, target_func, args=()):
        super().__init__()
        self.target_func = target_func
        self.args = args

    def run(self):
        # Chame a função alvo com os argumentos
        self.target_func(*self.args)


class cls_xlsx:
    def __init__(self, dados_json):
        self.dados_json = dados_json
        self.relacoes = processar_teste("relacoes","static/js/cfg_js.js")

    def substituir_com_relacoes(self,key):        
        if key in self.relacoes:
            return self.relacoes[key][0]  # Suponha que haja apenas um valor associado à chave
        return key
    
    def replace_xlsx(self, arquivo, destino, wkbactiv):
        retdata = self.dados_json   # Obtém o JSON dos dados enviados no corpo da solicitação
        retdata["teste"] = "novo item"

        # Crie um dicionário para mapear as substituições
        replace_dict = {}
        for key, value in retdata['retor']['reports'].items():
            replace_dict[key] = value

        # Carregue o arquivo Excel
        workbook = openpyxl.load_workbook(arquivo)

        # Itere pelas planilhas do arquivo Excel
        for sheet_name in workbook.sheetnames:
            if wkbactiv in workbook.sheetnames:
                sheet = workbook[sheet_name]
                # Itere pelas células da planilha
                for row in sheet.iter_rows(min_row=1, max_row=sheet.max_row, min_col=1, max_col=sheet.max_column):
                    for cell in row:
                        # Verifique se o conteúdo da célula contém alguma chave a ser substituída
                        cell_value = str(cell.value)
                        for key, replacement in replace_dict.items():
                            key = self.substituir_com_relacoes(key)
                            if key in cell_value:
                                # Realize a substituição no conteúdo da célula                            
                                cell_value = cell_value.replace(key, replacement)
                                cell.value = cell_value.replace("[", "").replace("]", "")
            
            else:
                raise KeyError(f"A planilha '{wkbactiv}' não existe no arquivo Excel.")
        # Salve as alterações no arquivo Excel
        sheet = workbook[wkbactiv]
        workbook.active = sheet
        workbook.save(destino)
        openfilewithapp(destino)
        self.convtojson(arquivo,rplextfile(destino,"json"))
        return jsonify({"mensagem": "JSON recebido com sucesso!", "dados": retdata})
    
    def inserir_xlsx(self,filename,jscfg,data,workative):
        workbook = self.criaxlsx(filename,workative)
        #data = processar_teste("dadosteste",jscfg)
        sheet = workbook.active   
        # Adicione cabeçalhos às colunas
        sheet["A1"] = "Variavel"
        sheet["B1"] = "Valor"    
        # Preencha os dados do JSON no Excel
        row_num = 2
        for item in data:
            sheet.cell(row=row_num, column=1, value="_"+item)
            sheet.cell(row=row_num, column=2, value="["+item+"]")
            #sheet.cell(row=row_num, column=2, value=data[item])
            row_num += 1    
        # Salve o arquivo Excel
        workbook.save(filename)    
        # Abra o arquivo Excel usando o sistema padrão
        openfilewithapp(filename)   
        return jsonify({"mensagem": "JSON recebido com sucesso!", "dados": data})
    
    def addsheet(self,workbook,sheet_name,filename):
        if sheet_name not in workbook.sheetnames:
            # Se não existir, crie uma nova planilha com esse nome
            workbook.create_sheet(title=sheet_name)
            sheet = workbook[sheet_name]
            workbook.active = sheet
            # Salve as alterações de volta no arquivo Excel
            workbook.save(filename)
    
    def criaxlsx(self,filename,wkbactiv):
        if not os.path.isfile(filename):
            # Se o arquivo não existe, cria uma nova pasta de trabalho
            workbook = openpyxl.Workbook()
            # Salva a pasta de trabalho no caminho especificado
            self.addsheet(workbook,"RESUMO",filename)
            self.addsheet(workbook,wkbactiv,filename)
        else:
            # Se o arquivo já existe, você pode carregá-lo normalmente
            workbook = openpyxl.load_workbook(filename)
            self.addsheet(workbook,wkbactiv,filename)       
        return workbook
    def convtojson(self,filename,filenamedest):
        # Carregar dados do Excel para um DataFrame
        excel_file = filename #'caminho/do/seu/arquivo/excel.xlsx'
        df = pandas.read_excel(excel_file)
        # Converter DataFrame para JSON
        json_data = df.to_json(orient='records')
        # Salvar JSON em um arquivo
        json_file = filenamedest #'caminho/do/seu/arquivo/json.json'
        with open(json_file, 'w') as f:
            f.write(json_data)
        print(f'Conversão concluída. Dados salvos em {json_file}')
    
class cls_js:
    def __init__(self, filenamejs):
        self.filename = filenamejs
        self.elefilejs = None
    def run_js(self):
        with open(self.filename, 'r') as arquivo_js:
            codigo_js = arquivo_js.read()
            self.elefilejs = execjs.compile(codigo_js)
    def getvar_js(self, namevar):
        if self.elefilejs is None:
            self.run_js()  # Compile o código JavaScript se ainda não tiver sido compilado
        return self.elefilejs.eval(namevar)

class cls_utils:
    def __init__(self, filename):
        self.filename = filename  # Corrigido o nome do atributo
    def setstdout(self):
        sys.stdout = cls_LoggingStreamHandler()
    def definelogs(self):
        # Obtém o diretório do executável
        exec_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
        script_dir = os.path.dirname(os.path.realpath(__file__))
        LOG_FOLDER = os.path.join(exec_dir, "logs")
        os.makedirs(LOG_FOLDER, exist_ok=True)

        log_file = os.path.join(LOG_FOLDER, self.filename)  # Usar self.filename aqui
        logging.basicConfig(
            filename=log_file,  # no arquivo / no console
            level=logging.DEBUG,
            format='%(asctime)s - %(levelname)s - %(message)s',
        )
        self.logging = logging
        return logging
# Cria um manipulador de log que redireciona a saída para o logging
class cls_LoggingStreamHandler(logging.StreamHandler):
    def emit(self, record):
        try:
            msg = self.format(record)
            logging.info(msg)
        except Exception:
            self.handleError(record)    
# Cria um manipulador de log que redireciona a saída para o logging
class cls_pdfutils:
    def __init__(self):
        self.filename = 'filename.pdf'  # Corrigido o nome do atributo
        
    def parsepdf(self,filname):
        pdf_leitor = PdfReader(filname)
        pag_conteudo = {}
        for indx, pdf_pag in enumerate(pdf_leitor.pages):
            pag_conteudo[indx+1] = pdf_pag.extract_text()
        return pag_conteudo
# classe para fazer distribuição de processos    
class cls_AlocadorProcessos:
    def __init__(self, capacidade_diaria):
        self.processos = [
            {"codproc": "1001", "data": "05/01/2024", "reagendar": "false"},
            {"codproc": "1000", "data": "05/01/2024", "reagendar": "false"},
            {"codproc": "1002", "data": "05/01/2024", "reagendar": "false"},
            {"codproc": "1003", "data": "05/01/2024", "reagendar": "false"},
            {"codproc": "1004", "data": "05/01/2024", "reagendar": "true"},
            {"codproc": "1005", "data": "05/01/2024", "reagendar": "true"},
            {"codproc": "1006", "data": "05/01/2024", "reagendar": "true"},
            {"codproc": "1007", "data": "06/01/2024", "reagendar": "true"},
            {"codproc": "1008", "data": "07/01/2024", "reagendar": "true"},
            {"codproc": "1009", "data": "05/01/2024", "reagendar": "true"},
            {"codproc": "1011", "data": "10/01/2024", "reagendar": "true"},
            {"codproc": "1012", "data": "09/01/2024", "reagendar": "true"},
            {"codproc": "1013", "data": "05/01/2024", "reagendar": "true"}
        ]
        self.capacidade_diaria = capacidade_diaria
        self.datacurr = datetime.strptime(self.processos[0]['data'], '%d/%m/%Y')
        self.processos_reagendados = [p for p in self.processos if p['reagendar'] == "true"]

    def getcount(self, field,reagen=None): 
        data_alvo_str = self.datacurr.strftime('%d/%m/%Y')
        if reagen !=None:
            itens_com_data_alvo = [item for item in self.processos if item[field] == data_alvo_str and item['reagendar'] == reagen ]
        else:
            itens_com_data_alvo = [item for item in self.processos if item[field] == data_alvo_str]
        numero_de_itens = len(itens_com_data_alvo)
        print(f"Número de itens {self.datacurr}: {numero_de_itens}")
        return numero_de_itens
    
    def alocar_processos(self):
     while any( self.getcount('data') > self.capacidade_diaria for p in self.processos):
        for processo in self.processos:
            if processo['reagendar'] == "true" and self.getcount('data') > self.capacidade_diaria:
                processo['data'] = self.encontrar_proximo_dia_util(processo['data']).strftime('%d/%m/%Y')
                proc =datetime.strptime(processo['data'], '%d/%m/%Y')
        self.datacurr = proc

    def encontrar_proximo_dia_util(self, data_str):
        data = datetime.strptime(data_str, '%d/%m/%Y')
        data += timedelta(days=1)
        while data.weekday() >= 5:  # 5 e 6 correspondem a sábado e domingo
            data += timedelta(days=1)
        return data

    def sample(self):
        self.alocar_processos()
        self.processos = sorted(self.processos, key=lambda x: datetime.strptime(x['data'], '%d/%m/%Y'))
        print(json.dumps(self.processos, indent=4))
        

#----------------------------------------------------------------------------------------------------
def processar_teste(varname,fname):    
    # Abra e leia o arquivo .js
    #codigo_js = openfilesystem('static/js/cfg_js.js')
    codigo_js = openfilefromresource(fname)
    # Execute o código JavaScript usando a biblioteca execjs
    contexto = execjs.compile(codigo_js)
    # Acesse a variável 'dados' do JavaScript no Python
    dados_js = contexto.eval(varname)
    # Agora 'dados_js' contém os dados do JavaScript no Python
    return dados_js

def exppdf(filextract):
    pdfext = cls_pdfutils()
    return pdfext.parsepdf(filextract)

# Função para criar diretórios se eles não existirem
def makerdirs():    
    # Verifique se os diretórios de destino existem e crie-os se necessário
    for pasta in ["uploads"]: #["dados", "templates", "static"]:'
        if not os.path.exists(pasta):
            os.makedirs(pasta)      

def embed_files(app,pasta,nome_arquivo):
     # Extraia e grave os arquivos da pasta "dados"
    for nome_arquivo in pkgutil.get_data(app, pasta).splitlines():
        caminho_destino = os.path.join(pasta, nome_arquivo)
        with open(caminho_destino, "wb") as destino:
            destino.write(pkgutil.get_data(app, f"{pasta}/{nome_arquivo}"))

def openfilewithapp(filename):        
    #os.system('start "" "' + filename + '"')    
    subprocess.Popen(['start', '', filename], shell=True)

def openfilefromresource(file):
    # Abra o arquivo incorporado usando pkg_resources
    resource_path = file  # O caminho relativo ao executável
    resource = pkg_resources.resource_string(__name__, resource_path)    
    # Agora, você pode trabalhar com o conteúdo do arquivo como uma string
    return resource.decode('utf-8')

def openfilesystem(file):
    with open(file, 'r') as arquivo_js:
        return arquivo_js.read()    

def distribuir():
    alocador = cls_AlocadorProcessos(3)
    alocador.sample()

def rplextfile(caminho, ext):
    # Dividir o caminho e a extensão do arquivo
    diretorio, nome_arquivo_extensao = os.path.split(caminho)
    nome_arquivo, _ = os.path.splitext(nome_arquivo_extensao)    
    # Substituir a extensão
    novo_caminho = os.path.join(diretorio, f"{nome_arquivo}.{ext}")
    return novo_caminho

def extract_text_from_pdf(pdf_path):
    """Extrai texto de um arquivo PDF."""
    text = ""
    with fitz.open(pdf_path) as doc:
        for page in doc:
            text += page.get_text()
    return text        