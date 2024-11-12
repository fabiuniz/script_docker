import sys
from PyQt5.QtWidgets import QApplication, QMainWindow 
from PyQt5.QtCore import QUrl ,QObject, pyqtSignal
from PyQt5.QtWebEngineWidgets import QWebEngineView
from lib_func import ServerThread

def runseverport(app,pt):
    app.run(port=pt)

class AppBrowser(QObject):
    server_finished = pyqtSignal()

    def __init__(self):
        super().__init__()

    def run(self,url): 
        app_qt = QApplication(sys.argv)
        self.window = QMainWindow()
        self.browser = QWebEngineView()       
        url = QUrl(url)
        self.browser.setUrl(url)        
        self.window.setCentralWidget(self.browser)
        self.window.show()
        app_qt.aboutToQuit.connect(self.quit_server)
        sys.exit(app_qt.exec_())

    def quit_server(self):
        self.server_finished.emit()

def quit_server(self):
    self.server_finished.emit()        

def runServerAndBrowser(app,url,port):
    # Inicia o servidor Flask na porta 8000 em um thread
    server_thread = ServerThread(runseverport, args=(app,port,))
    # Inicie a execução da thread
    server_thread.start()
    
    # Inicia Janela browser
    app_qt = AppBrowser()
    app_qt.server_finished.connect(server_thread.join)
    app_qt.run(url)
