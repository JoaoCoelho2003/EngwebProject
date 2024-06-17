# Introdução

O tema selecionado para o projeto da cadeira foi o `Mapa das Ruas de Braga`, pelo que o produto final desenvolvido consiste num site que tem como função principal apresentar o indíce das ruas da cidade de Braga.
Para este projeto, o grupo decidiu divergir um bocado da metodologia abordada na UC e explorar tecnologias novas, como é o caso da linguagem de programação **Elixir** e os seus frameworks **Phoenix** e **Ecto**, que foram usados para desenvolver esta aplicação web, e lidar com a a migração de dados para uma database.

# Funcionalidades implementadas

Foram implementadas as seguintes funcionalidades, com o objetivo de construir um produto capaz de assegurar uma boa experiência de utilização.  

### Autenticação

Cada utilizador pode (e deve) registar-se no sistema ao introduzir um e-mail, uma password e um username que o identifiquem, criando assim uma conta própria. Para que seja possível usufruir de grande parte das _features_, mais concretamente, posts de informação, o utilizador tem de efetuar o _login_, inserindo o seu e-mail e password na página apropriada para o efeito.

### Search Bar

Na página principal do site está presente uma barra de pesquisa, na qual o utilizador pode inserir texto, de modo a que o sistema lhe apresente apenas os resultados adequados. 

### Posts de novos registos

No caso do utilizador ter feito o _login_, este tem a possibilidade de criar um novo registo de uma rua, usando o botão _New Road_. Assim que este botão é pressionado, será pedido ao _user_ que preencha um formulário com as informações da rua, ou seja, o nome, a sua descrição, e múltiplas imagens que a representem, cada uma com uma legenda associada. 

Após a confirmação do preenchimento do formulário, aparece um novo _pop-up_, desta vez orientado para a informação referente às casas presentes na rua a ser criada. Nesta fase, o utilizador deve inserir os atributos de cada casa que decidir adicionar, uma a uma.

Desta forma, um novo registo é adicionado ao sistema, e pode ser acessado por outros utilizadores, no entanto, apenas o criador da rua poderá editar as informações da página, e até mesmo remover, ou inserir, imagens e casas.

Além da criação de novos registos como aqueles que foram mencionados, qualquer _user_ tem o poder de deixar comentários em qualquer página de rua disponível e "votar" nos cometários dos outros, colocando um _like_ ou um _dislike_. Todos os comentários são identificados pelo _username_ da conta associada, e podem dirigir os restantes utilizadores à página de perfil da pessoa em questão.

# Páginas desenvolvidas

## Página principal

Definida na `root`, a página principal contém a listagem das ruas da cidade de Braga. Cada entrada leva o utilizador para a rota correspondente à página da rua em questão. Os botões de login e registo levam às suas respetivas páginas.

## Página de registo

A rota `/users/register` apresenta o formulário de registo de um utilizador. Assim que o _user_ preencher os _input fields_ com o seu e-mail, palavra-passe, nome de utilizador e clicar no botão para criar a conta, este é redirecionado para a página principal, mas desta vez com o login já efetuado.

## Página de login

A rota `/users/log_in` dirige-nos aos campos a preencher para entrar no sistema com a nossa conta. A partir daí podemos efetuar o _login_ e entrar na página principal, mas também é possível carregar num link presente apenas para o caso de nos esquecermos da nossa _password_.

## Redefinir palavra-passe

Em `/users/reset_password`, podemos indicar o nosso _mail_ para efetuar o pedido desejado.

## Página de perfil

Na eventualidade do _user_ ter uma sessão ativa e se encontrar na página principal, este pode usar o botão do perfil, localizado no canto superior direito do ecrã, para aceder à sua página de perfil, carregando na opção correspondente no _dropdown_ apresentado. Isto leva o _user_ para a rota `/users/#{user_id}/profile` em que user_id se refere ao identificador numérico do próprio utilizador no sistema.

Nesta página é possível observar as informações da conta, assim como as ruas criadas por ela e os comentários que fez, escolhendo uma das duas _tabs_ definidas para isso, que modifcam ligeiramente a rota, alterando-a para `/users/#{user_id}/profile?tab=#{tab}`.

## Configuração de perfil

Se o utilizador decidir clicar no botão das _settings_ no _dropdown_ do botão de perfil, este é redirecionado para `/users/settings`, onde lhe é permitido alterar o seu e-mail e a sua palavra-passe, preenchendo os respetivos _fields_.

## Página de rua

A página de uma rua pode ser acessada a partir da página principal, e a sua rota correspondente é `/roads/#{road.id}`, sendo que road.id representa o número identificador da rua. Nesta página são exibidos o número da rua, o seu nome e uma descrição sobre a rua, assim como imagens atuais e antigas. Podemos também ler sobre a enfiteuta e o foro das diferentes casas, em adição a uma breve descrição de cada uma.

No final da página encontra-se um _text field_ para que o utilizador possa deixar os seus comentários, e um botão que redireciona o _user_ para a página principal do site.

## Adicionar rua

## Adicionar casas

## Adicionar imagem

## Remover imagem

## Editar rua

## Remover rua

## Editar casa

## Remover casa







