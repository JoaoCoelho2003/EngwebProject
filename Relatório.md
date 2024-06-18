# Introdução

O tema selecionado para o projeto da cadeira foi o `Mapa das Ruas de Braga`, pelo que o produto final desenvolvido consiste num site que tem como função principal apresentar o indíce das ruas da cidade de Braga.
Para este projeto, o grupo decidiu divergir um bocado da metodologia abordada na UC e explorar tecnologias novas, como é o caso da linguagem de programação **Elixir** e os seus frameworks **Phoenix** e **Ecto**, que foram usados para desenvolver esta aplicação web, e lidar com a a migração de dados para uma database.

# Funcionalidades

Foram implementadas as seguintes funcionalidades, com o objetivo de construir um produto capaz de assegurar uma boa experiência de utilização.  

### Autenticação

Cada utilizador pode (e deve) registar-se no sistema ao introduzir um e-mail, uma password, o seu nome e, por fim, a sua filiação, criando assim uma conta própria. Para que seja possível usufruir de grande parte das _features_, mais concretamente, posts de informação, comentários, entre outros, o utilizador tem de efetuar o _login_, inserindo o seu e-mail e password na página apropriada para o efeito. Todo o processo de autenticação é feito através de _tokens_ de sessão, que são guardados no _cookie_ do _browser_ do utilizador.

### Recuperação de password

Caso o utilizador se esqueça da sua password, este pode pedir para a mesma ser redefinida, inserindo o seu e-mail na página de recuperação de password. Assim que o pedido é feito, o utilizador recebe um e-mail com um link que o redireciona para uma página onde pode definir uma nova password.

### Search Bar

Na página principal do site está presente uma barra de pesquisa, na qual o utilizador pode inserir texto, de modo a que o sistema lhe apresente apenas os resultados adequados. 

### Criação de novos registos de ruas

No caso do utilizador ter feito o _login_, este tem a possibilidade de criar um novo registo de uma rua, usando o botão _Adicionar Rua_. Assim que este botão é pressionado, será pedido ao _user_ que preencha um formulário com as informações da rua, ou seja, o nome, a sua descrição, e múltiplas imagens que a representem, cada uma com uma legenda associada. 

Após a confirmação do preenchimento do formulário, aparece um novo _pop-up_, desta vez orientado para a informação referente às casas presentes na rua a ser criada. Nesta fase, o utilizador deve inserir os atributos de cada casa que decidir adicionar, uma a uma.

Desta forma, um novo registo é adicionado ao sistema, e pode ser acessado por outros utilizadores, no entanto, apenas o criador da rua ou um admin da aplicação poderá editar as informações da página, e até mesmo remover, ou inserir, imagens e casas.

### Comentários

Os utilizadores autenticados podem deixar comentários nas páginas das ruas, que são visíveis para todos os utilizadores. Cada comentário é associado ao utilizador que o fez, e à rua a que se refere. Para além disso, o utilizador pode editar ou remover os seus próprios comentários e, é possível visualizar o perfil do utilizador que fez o comentário, clicando no seu nome.

### Download de registos

Os utilizadores podem fazer o download de um registo de rua, em formato zip, que contém todas as imagens associadas à rua, assim como as informações referentes à rua e às suas casas. Para tal, basta clicar no botão de download, localizado na página principal, ao lado da rua que se deseja descarregar.

### Perfil de utilizador

Como já foi referido, cada utilizador tem a sua própria página de perfil, onde pode ver as suas informações pessoais, assim como os registos de ruas que criou e os comentários que fez. A página de perfil é acessível através do botão de perfil, localizado no canto superior direito da página principal, e é possível alterar o e-mail e a password do utilizador, acedendo às configurações da conta.

# Páginas desenvolvidas

## Página principal

Definida na rota `/`, a página principal contém a listagem das ruas da cidade de Braga. Cada entrada leva o utilizador para a rota correspondente à página da rua em questão. Os botões de login e registo levam às suas respetivas páginas.

![Página Principal](/assets/paginaPrincipal.png)

## Página de registo

A rota `/users/register` apresenta o formulário de registo de um utilizador. Assim que o _user_ preencher os _input fields_ com o seu e-mail, palavra-passe, nome de utilizador e filiação, ao clicar no botão para criar a conta, este é redirecionado para a página principal, mas desta vez com o login já efetuado.

![Página de Registo](/assets/paginaRegisto.png)

## Página de login

A rota `/users/log_in` dirige-nos aos campos a preencher para entrar no sistema com a nossa conta. A partir daí podemos efetuar o _login_ e entrar na página principal, mas também é possível carregar num link presente apenas para o caso de nos esquecermos da nossa _password_.

![Página de Login](/assets/paginaLogin.png)

## Redefinir palavra-passe

Em `/users/reset_password`, podemos indicar o nosso _mail_ para efetuar o pedido desejado.

![Página de Reset Password](/assets/paginaResetPassword.png)

## Página de perfil

Na eventualidade do _user_ ter uma sessão ativa e se encontrar na página principal, este pode usar o botão do perfil, localizado no canto superior direito do ecrã, para aceder à sua página de perfil, carregando na opção correspondente no _dropdown_ apresentado. Isto leva o _user_ para a rota `/users/#{user_id}/profile` em que user_id se refere ao identificador numérico do próprio utilizador no sistema.

Nesta página é possível observar as informações da conta, assim como as ruas criadas por ela e os comentários que fez, escolhendo uma das duas _tabs_ definidas para isso, que modificam ligeiramente a rota, alterando-a para `/users/#{user_id}/profile?tab=#{tab}`.

![Página do Perfil](/assets/paginaPerfil.png)

## Configuração da conta

Se o utilizador decidir clicar no botão das _settings_ no _dropdown_ do botão de perfil, este é redirecionado para `/users/settings`, onde lhe é permitido alterar o seu e-mail e a sua palavra-passe, preenchendo os respetivos _fields_.

![Definições](/assets/paginaDefinicoes.png)

## Adicionar rua

Carregando no botão _Adicionar Rua_ presente na página principal (tendo uma sessão ativa), o _user_ é levado para a rota `/roads/new`, onde se depara com o formulário requirido para inserir as informações da rua a ser criada. Assumindo que o utilizador deseja seguir em frente, este pode usar o botão Save Road, para ser orientado para a próxima página, onde este terá que especificar as casas que deseja adicionar à rua.

![Adicionar Rua](/assets/adicionarRua.png)

## Adicionar casas

Em seguimento do processo de post de uma rua nova, assim que o _user_ segue para a rota `/roads/#{road.id}/houses`, este depara-se com outro formulário, no qual pode inserir as informações referentes às casas da rua, adicionando e removendo casas como lhe convém.

Aqui está um exemplo do formulário inicial:

![Adicionar Casas](/assets/adicionarCasasVazio.png)

E aqui um exemplo de um formulário preenchido:

![Adicionar Casas Preenchido](/assets/adicionarCasasPreenchido.png)



## Página da rua

A página de uma rua pode ser acessada a partir da página principal, e a sua rota correspondente é `/roads/#{road.id}`, sendo que road.id representa o número identificador da rua. Nesta página são exibidos o número da rua, o seu nome e uma descrição sobre a rua, assim como imagens atuais e antigas. Podemos também ler sobre a enfiteuta e o foro das diferentes casas, em adição a uma breve descrição de cada uma.

![Página da Rua](/assets/paginaRua.png)
![Página da Rua 2](/assets/paginaRua2.png)

No final da página encontra-se um _text field_ para que o utilizador possa deixar os seus comentários, e um botão que redireciona o _user_ para a página principal do site.

![Comentários](/assets/comentarios.png)

- ### Adicionar imagem e Remover Imagem
  
A rota `/roads/#{road.id}/current_image/new` pode ser alcançada pelo pequeno botão de adicionar imagens na página de uma rua, desde que esta tenha sido criada pelo próprio utilizador. Aqui é possível fazer o _upload_ de uma nova imagem para a página.

Alternativamente, se o objetivo for adicionar uma imagem antiga da rua, a rota passa a ser `/roads/#{road.id}/image/new`, mas o conteúdo apresentado é igual.

Para remover uma imagem, segue-se a mesma lógica que no processo anterior, mas desta vez o botão de remoção localiza-se em baixo da figura, e o _pop-up_ de confirmação do _delete_ corresponde às rotas `/roads/#{road.id}/current_image/#{image.id}/delete` e `/roads/#{road.id}/image/#{image.id}/delete`.

Tal como já foi referido anteriormente, estas features só podem ser observadas caso o utilizador em questão seja o dono do registo ou um admin. É possível averiguar a sua presença a partir dos butões presentes na página da rua ao lado das imagens.

![Butões Imagens](/assets/butoesImagens.png)

- ### Editar rua

O botão de editar rua, ao qual apenas o dono da rua tem acesso, dirige o usuário para `/roads/#{road.id}/edit`, onde este pode escrever um novo nome e descrição para a rua, e guardar os novos dados no sistema.

![Editar Rua](/assets/editarRua.png)

- ### Remover rua

Para fazer o _delete_ da rua, o botão a selecionar é o de eliminar rua, localizado à direita do botão de editar, e à semelhança desse, apenas o dono da rua o pode ver. Carregando no botão, o dono da rua é levado para `/roads/#{road.id}/delete`, onde pode confirmar a sua decisão e remover o registo do sistema.

![Remover Rua](/assets/removerRua.png)

- ### Editar casa e Remover casa
O dono da rua pode também editar as casas que adicionou no processo de criação da rua. Isto é feito através do botão de editar casa, que o leva para `/roads/#{road.id}/house/#{house.id}/edit`. Nessa rota, acede-se a um formulário com vários _fields_ para alterar a informação textual da casa selecionada.

Como seria de esperar, também é possível remover uma casa, sendo o dono da rua em que esta se encontra, usando o botão de eliminação de casa, que altera a rota atual para `/roads/#{road.id}/house/#{house.id}/delete`. Aqui é feita a confirmação do processo de _delete_ do registo.

![Editar e Remover Casa](/assets/editarRemoverCasa.png)

As páginas de editar e remover uma casa são quase idênticas às de editar e remover uma rua.

- ### Editar e Remover Comentários

O utilizador que fez um comentário numa rua pode editá-lo ou removê-lo, clicando nos botões correspondentes, que se encontram ao lado do seu comentário. Ao clicar no botão de edição, o _user_ é redirecionado para `/roads/#{road.id}/comment/#{comment.id}/edit`, onde pode alterar o conteúdo do seu comentário. Por outro lado, ao clicar no botão de remoção, o comentário é eliminado do sistema.

![Editar e Remover Comentários](/assets/editarRemoverComentarios.png)

Finalmente, falta a foto do _pop-up_ de edição de um comentário:

![Editar Comentário](/assets/editarComentario.png)

# Tratamento de Dados

Desenvolvemos um _script_ em Python, [data_migrator.py](/scripts/xmlToJson.py), que lê os diversos ficheiros XML fornecidos pelo professor, e junta toda a informação num único ficheiro JSON, que é usado para popular a base de dados da aplicação recorrendo ao _seed_ do Phoenix.
Este script remove as _tags_ desnecessárias das descrições das ruas e casas (lugar e data), e converte as _tags_ das imagens para que seja mais fácil de as manipular no _front-end_ e adiciona a informação das imagens atuais, escrevendo o resultado no ficheiro JSON na pasta `priv/fake/roads.json`.

# Instruções de Uso

## Docker

Caso queira usufruir do docker desenvolvido, basta correr o seguinte comando:

```bash
$ (sudo) docker compose up --build
```

Caso esteja a utilizar um dispositivo com o MacOS, é necessário substituir:

```bash
services:
  db:
    network_mode: "host"
  web:
    network_mode: "host"
```

Por:

```bash
services:
  db:
    ports:
      - ${DB_PORT:-5555}:5432
  web:
    ports:
      - ${PORT:-4000}:4000
```

## Mix

Por outro lado, caso queira usar os comandos disponibilizados pelo mix:

```bash
$ mix setup
$ mix phx.server
```

# Contas

Existem 3 contas guardadas no sistema por _default_.
 - admin@mail.pt (role: admin)
 - joaocoelho@mail.pt
 - joserodrigues@mail.pt
 - duartearaujo@mail.pt
 - passwords: password1234

# Importar e Exportar

Para importar e exportar os dados para a base de dados, basta correr os seguintes comandos:

```bash
$ bash import.sh
$ bash export.sh
```

# Considerações Finais

O projeto foi desenvolvido com o intuito de proporcionar uma experiência de utilização agradável e intuitiva, e de explorar tecnologias novas, como é o caso do Elixir e do Phoenix. Acreditamos que o resultado final é satisfatório, e que o site desenvolvido cumpre os requisitos propostos, oferecendo um serviço útil e interessante para os utilizadores.
No entanto, existem algumas melhorias que poderiam ser feitas, como por exemplo:

- Upload de XMLs que contêm informação sobre as ruas e casas diretamente no site, para que o utilizador possa adicionar novos registos de forma mais simples.

- Mais opções de login para o utilizador, como por exemplo, através de uma conta Google ou Facebook.

- Adição de filtros de pesquisa, para que o utilizador possa encontrar as ruas de forma mais rápida e eficiente.

Por fim, é importante referir que o projeto corre na porta 4000.

# Autores

- [João Coelho(A100596)](https://github.com/JoaoCoelho2003)

- [José Rodrigues(A100692)](https://github.com/FilipeR13)

- [Duarte Araújo(A100750)](https://github.com/duartearaujo)






