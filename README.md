# Arandu - Plataforma de Ensino Síncrono Interativa com Ferramentas de IA

Este projeto pessoal foi desenvolvido com o objetivo de aprendizado orientado por um projeto, abrangendo todas as etapas do desenvolvimento fullstack. Esta plataforma de ensino síncrono foi desenvolvida com foco em interatividade e utilizando diversas tecnologias modernas como de ferramentas de IA para proporcionar uma experiência de aprendizado rica e envolvente.


## Visão Geral

O projeto consiste em uma plataforma que permite a transmissão em tempo real de aulas interativas, incorporando diversas ferramentas que facilitam a interação entre alunos e professores. Abaixo, uma visão geral das principais funcionalidades e tecnologias utilizadas:

## Funcionalidades

### 1. Servidor de Mídia
- **Tecnologia Utilizada:** Mediasoup (WebRTC)
- **Descrição:** Implementação de uma SFU (Selective Forwarding Unit) para transmissão eficiente de mídia e dados em tempo real.

### 2. Compartilhamento de Conteúdo
- **Descrição:** Permite que o professor compartilhe diversos formatos de mídia, incluindo slides, PDFs, vídeos e editores de código diretamente na plataforma. São incorporados no HTML para que o aluno consiga acessar o conteúdo de forma independente e autônoma.

### 3. Ferramentas de Interação
- **Chat Livre:** Um canal de comunicação aberto entre alunos e professor para discussões em tempo real.
- **Sistema de Perguntas Ranqueadas:** Alunos podem fazer perguntas que são ranqueadas por relevância, garantindo que as dúvidas mais importantes sejam priorizadas.

### 4. Chatbot com Contexto da Aula
- **Tecnologias Utilizadas:** Langchain, OpenAI API, Google Cloud Functions
- **Descrição:** Um chatbot inteligente que entende o contexto da aula, ajudando alunos com dúvidas e fornecendo informações relevantes durante a transmissão.

### 5. Frontend Interativo
- **Tecnologia Utilizada:** JavaScript (Imba)
- **Componentes:**
  - **Planejamento da Aula:** Ferramenta para o professor organizar e planejar o conteúdo da aula.
  - **Interface de Transmissão do Professor:** Interface onde o professor controla a transmissão ao vivo e interage com as ferramentas disponíveis.
  - **Interface do Aluno:** Interface intuitiva para os alunos acompanharem a aula, interagirem com o conteúdo e utilizarem o chat e o sistema de perguntas.

## Tecnologias e Ferramentas Utilizadas

- **Backend:** Mediasoup (WebRTC), Google Cloud Functions, Firebase
- **Frontend:** JavaScript (Imba)
- **Chatbot:** Langchain, OpenAI API
- **Serviços de Nuvem:** Google Cloud, Firebase

## Como Executar o Projeto

### Requisitos

- Node.js versão >= v16.0.0
- NPM/Yarn
- Python versão >= 3.7 com PIP
- Conta na Google Cloud para utilizar as Google Cloud Functions e Firebase.

### Passos para Execução

1. **Clone o Repositório:**
    ```bash
    git clone https://github.com/pedror-py/arandu-interactive-online-classes.git
    ```

2. **Instale as Dependências:**
    ```bash
    npm install
    ```

3. **Configure as Variáveis de Ambiente:**
    - Configure as credenciais do Google Cloud e Firebase

4. **Execute o Servidor de Mídia:**
    ```bash
    npm run server
    ```

5. **Execute o Frontend:**
    ```bash
    npm run dev
    ```

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**Contato:**
- Pedro de Freitas Ribeiro
- pedro.freitas.ribeiro12@gmail.com
- [LinkedIn](linkedin.com/in/pedro-ribeiro-phd-790541302)

---
