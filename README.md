# DManga

DManga é um script/programa ruby multiplataforma Window/Linux/Mac 
para baixar mangas de mangahost.net. Com ele voce pode baixar 
qualquer manga hospedado em mangahost.net(site br de hospedagem de
manga) de forma automatizada e sem restrição de quantidade. Basta 
dizer o nome do manga e selecionar os capitulos que deseja baixar 
e pronto o script fará os downloads do capitulos selecionados.

## Instalação

### Windows
Primeiro você precisa ter ruby instalado, você pode baixar ruby 
deste [site](https://rubyinstaller.org/downloads/), basta baixar 
um dos instaladores que estão abaixo do titulo 'RubyInstallers',
algo com o nome similar a Ruby-2.3.3 (pode ser uma versao superior).
Com o ruby instalado baixe o script/programa e descompacte-o.

Obs: Esse passo a passo consida que os arquivos foram descompactados  
e estão na pasta Downloads.

Abra o prompt de comando.

No prompt digite:

`cd Downloads/dmanga`

Digite Enter para executar o comando.

Em seguida no prompt digite:

`rake install`

Com isso o script/programa será instalado. Apõs instalado os 
arquivos baixados podem ser apagados.

### Linux (debian/ubuntu)
Baixe o script/programa e descompacte-o.
Considerando que os arquivos foram descompactados na pasta Downloads
abra o terminal.

Digite:

`$ sudo apt-get install ruby`

Em seguida:

`$ cd /home/SeuNomeDeUsuario/Downloads/dmanga && rake install`

Onde está SeuNomeDeUsuarion deve ser colocado o seu nome de usuario
linux. 

Obs: Eu não cheguei a testar em versões do ruby abaixo do 2.3.3,
em caso de problema procure na internet como instalar a versão do
ruby 2.3.3 ou superior.

## Uso

`dmanga [opões] <nome do manga>`

Ex1:

`dmanga "one piece"`

Ex2:

`dmanga tomo-chan`


obs: o nome do manga não precisa ser o nome exato, pode ser parte do
nome ou alguma palavra contida no nome, em todo caso o script/programa
fará uma busca no site com o nome passado.

obs: se o nome do manga contiver mais de uma palavra coloque-o 
entre aspas.

obs: você pode dizer a pasta de destino do download com a opçao -d,
veja **Opções** para mais detalhes.


O scrip/program mostará os mangas encontrados com na busca no site 
um de cada vez, selecione o que corresponde a sua busca.

Após será mostrada a list de capitulos encontrados para aquele manga.

Quando ele perguntar "Quais capitulos você que baixar?", digite
uma das sequintes opções:

Para baixar todos so capitulos:

`todos`

Baixa todos os capitulos disponiveis.

Para selecionar um intervalo digite:

`inicio-fim`

Ex1:

`10-222`

Baixa do capitulo 10 ao 222.

Ex2:

`1-1l`

Baixa do capitulo 1 ao 11.

Se voce quiser baixar de um certo capitulo ao ultimo, basta digitar
no limite superior do intervalo um numero maior que o numero do
ultimo capitulo.

Para selecionar capitulos especificos:

`numeroDoCapitulo,numeroDoCapitulo,numeroDoCapitulo`

Ex:

`2,5,130`

Baixa os capitulos 2, 5 e 130.

Obs: os numeros dos capitulos devem ser digitados separados por
virgula e **sem espaços**.

### Opções

`--version`

Mostra o numero da versao do programa e sai.

`-d <pasta de download>, --directory <pasta de download>`

A pasta de destino do downlaod.

`-h , --help`

Mostra a messagem de ajuda e sai.

`-v , --verbose`

Mostra detalhes da execução do programa.

A pasta de destino do downlaod.

### Exemplos

`dmanga -d "c:\window\users\images\manga e animes" "One piece"`

No windows, baixe 'One piece' para
'c:\window\users\images\manga e animes'

`dmanga "One punch man"`

Baixe 'One punch man' para 'Downloads'. 

`dmanga -d /home/usuario/Images/mangas tomo-chan`

No linux baixe 'tomo-chan' para '/home/usuario/Images/mangas'. 

### Exemplos de seleção de capitulos

`todos`

Baixa todos os capitulos.

`34-96`

Baixa do capitulos do 34 ao 96.

`1,3,55`

Baixa do capitulos 1, 2 e 55.

`34,124`

Baixa do capitulos 34 e 124.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
