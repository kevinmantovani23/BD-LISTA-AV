USE ex9

--1) Consultar nome, valor unitário, nome da editora e nome do autor dos livros do estoque que foram vendidos. 
--Não podem haver repetições.	
SELECT DISTINCT es.nome as livro, es.valor, ed.nome as editora, au.nome as autor
FROM estoque es, compra cp, editora ed, autor au
WHERE es.codigo = cp.codEstoque AND
	  es.codEditora = ed.codigo AND
	  es.codAutor = au.codigo



--2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051	
SELECT es.nome as livro, cp.qtdComprada, cp.valor
FROM estoque es, compra cp
WHERE es.codigo = cp.codEstoque AND
	  cp.codigo = 15051


--3) Consultar Nome do livro e site da editora dos livros da Makron books
--(Caso o site tenha mais de 10 dígitos, remover o www.).	
SELECT es.nome as livro, 
	site = CASE WHEN (LEN(ed.site) > 10)
		THEN
		SUBSTRING(ed.site, 5 , LEN(ed.site))
		ELSE
		ed.site
		END
FROM estoque es, editora ed
WHERE es.codEditora = ed.codigo AND
	  ed.nome = 'Makron books'

--4) Consultar nome do livro e Breve Biografia do David Halliday	
SELECT es.nome, au.biografia
FROM estoque es, autor au
WHERE es.codAutor = au.codigo AND
	  au.nome = 'David Halliday'


--5) Consultar código de compra e quantidade comprada do livro Sistemas Operacionais Modernos	
SELECT cp.codigo, cp.qtdComprada
FROM compra cp, estoque es
WHERE cp.codEstoque = es.codigo AND
	  es.nome = 'Sistemas Operacionais Modernos'

--6) Consultar quais livros não foram vendidos	
SELECT es.nome as livronaovendido
FROM estoque es
 LEFT OUTER JOIN compra cp
 ON es.codigo = cp.codEstoque
 WHERE cp.codEstoque IS NULL


--7) Consultar quais livros foram vendidos e não estão cadastrados. Caso o nome dos livros terminem com espaço, 
--fazer o trim apropriado.	
SELECT RTRIM(es.nome) as livro, cp.codigo, cp.codEstoque
FROM compra cp
 LEFT OUTER JOIN estoque es 
 ON cp.codEstoque = es.codigo
 WHERE es.codigo IS NULL


--8) Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha mais de 10 dígitos, remover o www.)	
SELECT ed.nome, 
    site = CASE WHEN (LEN(ed.site) > 10)
		THEN
		SUBSTRING(ed.site, 5 , LEN(ed.site))
		ELSE
		ed.site
		END
FROM editora ed
 LEFT OUTER JOIN estoque es
 ON es.codEditora = ed.codigo
 WHERE es.codEditora IS NULL

--9) Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)	
SELECT au.nome,
	CASE WHEN(au.biografia LIKE 'Doutorado%') THEN
		'Ph.D' + SUBSTRING(au.biografia, 10, LEN(au.biografia))
		ELSE au.biografia
		END as biografia

FROM autor au
 LEFT OUTER JOIN estoque es
 ON es.codAutor = au.codigo
 WHERE es.codAutor IS NULL

--10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente	
SELECT au.nome as autor, es.nome as livro, es.valor
FROM autor au, estoque es
WHERE au.codigo = es.codAutor
ORDER BY es.valor DESC

--11) Consultar o código da compra, o total de livros comprados e a soma dos valores gastos. 
--Ordenar por Código da Compra ascendente.	

SELECT cp.codigo, SUM(cp.qtdComprada) as totallivros, SUM(cp.valor) as somavalores
FROM compra cp
GROUP BY cp.codigo
ORDER BY cp.codigo ASC

--12) Consultar o nome da editora e a média de preços dos livros em estoque.Ordenar pela Média de Valores ascendente.	

SELECT ed.nome, CAST(AVG(es.valor) AS DECIMAL(4,1)) as mediapreco
FROM editora ed, estoque es
WHERE ed.codigo = es.codEditora
GROUP BY ed.nome
ORDER BY mediapreco ASC

--13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora
--(Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna status onde:	
	--Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
	--Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
	--Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
	--A Ordenação deve ser por Quantidade ascendente

SELECT es.nome, es.quantidade, ed.nome,  site = CASE WHEN (LEN(ed.site) > 10)
		THEN
		SUBSTRING(ed.site, 5 , LEN(ed.site))
		ELSE
		ed.site
		END,
	  CASE
		  WHEN es.quantidade < 5 THEN
		  'Produto em Ponto de Pedido'
		  WHEN es.quantidade >= 5 AND es.quantidade <= 10 THEN
		  'Produto Acabando'
		  WHEN es.quantidade > 10 THEN
		  'Estoque Suficiente'
		  END as status
FROM estoque es, editora ed
WHERE es.codEditora = ed.codigo
ORDER BY es.quantidade ASC


--14) Para montar um relatório, é necessário montar uma consulta com a seguinte saída: 
--Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
		--Só pode concatenar sites que não são nulos

SELECT es.codigo, es.nome as livro, au.nome as autor, 
	CASE WHEN(ed.site IS NOT NULL) THEN
		ed.nome + ' ' + ed.site
	ELSE
		'Não possui site'
	END as infoeditora
FROM estoque es, autor au, editora ed
WHERE es.codEditora = ed.codigo AND
	  es.codAutor = au.codigo

--15) Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da compra até hoje	
SELECT cp.codigo, DATEDIFF(DAY, cp.dataCompra, GETDATE()) as diasdacompra, 
DATEDIFF(MONTH, cp.dataCompra, GETDATE()) as mesesdacompra
FROM compra cp


--16) Consultar o código da compra e a soma dos valores gastos das compras que somam mais de 200.00	

SELECT cp.codigo, 
	SUM(cp.valor) as somagastos
FROM compra cp
GROUP BY cp.codigo
HAVING SUM(cp.valor) > 200
