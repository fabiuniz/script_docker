function fazerGET() {
  /* Configuração da solicitação*/
  const requestOptions = {
    method: 'POST', /* ou 'GET' ou outro método HTTP, dependendo do que você precisa*/
    headers: {
      'Content-Type': 'application/json ; charset=UTF-8' /* Define o tipo de conteúdo como JSON*/
    },
    body: JSON.stringify(meuJSON) /* Converte o objeto JSON em uma string JSON*/
  };
  /* Fazer uma solicitação GET para o servidor Flask*/
  fetch('/process', requestOptions)
    .then(response => response.json())
    .then(data => {
      console.log(data);
      alert(data); /* Exibir a resposta em um alerta*/
    })
    .catch(error => {
      console.error('Erro ao fazer GET:', error);
    });
}
function fazerGETb() {
  /* Fazer uma solicitação GET para o servidor Flask*/
  fetch('/processb')
    .then(response => response.text())
    .then(data => {
      alert(data); /* Exibir a resposta em um alerta*/
    })
    .catch(error => {
      console.error('Erro ao fazer GET:', error);
    });
}
function fazerGETc() {
  /* Configuração da solicitação*/
  const requestOptions = {
    method: 'POST', /* ou 'GET' ou outro método HTTP, dependendo do que você precisa*/
    headers: {
      'Content-Type': 'application/json ; charset=UTF-8' /* Define o tipo de conteúdo como JSON*/
    },
    body: JSON.stringify(dadosjson) /* Converte o objeto JSON em uma string JSON*/
  };
  /* Fazer uma solicitação GET para o servidor Flask*/
  fetch('/xlsx', requestOptions)
    .then(response => response.json())
    .then(data => {
      console.log(data);
    })
    .catch(error => {
      console.error('Erro ao fazer GET:', error);
    });
}
function fazerGETd() {
  /* Configuração da solicitação*/
  const requestOptions = {
    method: 'POST', /* ou 'GET' ou outro método HTTP, dependendo do que você precisa*/
    headers: {
      'Content-Type': 'application/json ; charset=UTF-8' /* Define o tipo de conteúdo como JSON*/
    },
    body: JSON.stringify(dadosjson) /* Converte o objeto JSON em uma string JSON*/
  };
  /* Fazer uma solicitação GET para o servidor Flask*/
  fetch('/makexlsx', requestOptions)
    .then(response => response.json())
    .then(data => {
      console.log(data);
    })
    .catch(error => {
      console.error('Erro ao fazer GET:', error);
    });
}
function extraipdfs() {
  /* Configuração da solicitação*/
  const requestOptions = {
    method: 'POST', /* ou 'GET' ou outro método HTTP, dependendo do que você precisa*/
    headers: {
      'Content-Type': 'application/json ; charset=UTF-8' /* Define o tipo de conteúdo como JSON*/
    },
    body: JSON.stringify(dadosjson) /* Converte o objeto JSON em uma string JSON*/
  };
  /* Fazer uma solicitação GET para o servidor Flask*/
  fetch('/extraipdfs', requestOptions)
    .then(response => response.json())
    .then(data => {
      console.log(data);
    })
    .catch(error => {
      console.error('Erro ao fazer GET:', error);
    });
}