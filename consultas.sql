--Encriptar datos
--apta para modificaciones
UPDATE clientes
SET ContraCli = AES_ENCRYPT('tuvidaymivida', 'AES')
WHERE ClientesID = 6;

--descencreptar todos los datos
select CAST(aes_decrypt(ContraCli, 'AES')AS CHAR (50))recuperado from clientes;

select ClientesID, clientes, (aes_decrypt(ContraCli, 'AES'))recuperado from clientes;

--desecencriptar datos
UPDATE clientes
SET ContraCli = AES_DECRYPT(AES_ENCRYPT('jamesjamesjamess', 'AES'), 'AES')
WHERE ClientesID = 3;

--insertar encriptado 
INSERT INTO `clientes` (`ClientesID`, `Clienombre`, `Cliapellido`, `Clidirec`, `Clitel`, `CorreoCli`, `ContraCli`, `Cliestado`) VALUES
(1, 'Jimin Alexandro', 'Park Cazano', 'Calle 114 #7-67', '3115678454', 'Jimingaticomalo@gmail.com', aes_encrypt('jiminpark', 'AES')), 'Activo');

-- 1. Obtener el promedio de ventas por categoría de producto
SELECT categoria.CatNombre, AVG(pagos.monto_Pago) AS promedio_ventas
FROM categoria
JOIN productos ON categoria.CatID = productos.CatID
JOIN detalle_pedido ON productos.ProdID = detalle_pedido.ProdID
JOIN pagos ON detalle_pedido.PedidoID = pagos.PedidoID
GROUP BY categoria.CatNombre;

--2. Obtener la lista de los productos mas vendidos por categoria.
SELECT c.CatNombre AS categoria, p.ProdNombre AS productos, SUM(d.DePecantidad) AS total_vendido 
FROM detalle_pedido d 
JOIN pedido e ON d.PedidoID = e.PedidoID 
JOIN productos p ON d.ProdID = p.ProdID 
JOIN categoria c ON p.CatID = c.CatID 
WHERE e.Pedfecha >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) 
GROUP BY c.CatNombre, p.ProdNombre 
ORDER BY total_vendido DESC;

--3. Obtener el tiempo promedio de entrega por método de envío
SELECT envio.metodo_En, AVG(DATEDIFF(envio.Enfecha_envio, pedido.Pedfecha)) AS tiempo_promedio
FROM envio
JOIN pedido ON envio.PedidoID = pedidos.PedidoID
GROUP BY envio.metodo_En;

--4. Lista de Clientes con sus Compras Recientes
SELECT c.ClientesID, c.Clienombre, cc.carfecha_hora
FROM clientes c
JOIN carrito_compras cc ON c.ClientesID = cc.ClientesID 
WHERE cc.Carfecha_hora >= NOW() -INTERVAL 30 DAY;

--5. Obtener el total de productos en cada categoría
SELECT c.CatNombre, COUNT(p.ProdID) AS TotalProductos
FROM categoria c
LEFT JOIN productos p ON c.CatID = p.CatID
GROUP BY c.CatID;

--6. Ventas Totales por Mes y por Categoría
SELECT DATE_FORMAT(p.Pedfecha, '%Y-%m') AS Mes, cat.CatNombre, SUM(dp.DePecantidad * dp.DePedprecio_uni) AS TotalVentas
FROM pedido p
JOIN detalle_pedido dp ON p.PedidoID = dp.PedidoID
JOIN productos prod ON dp.ProdID = prod.ProdID
JOIN categoria cat ON prod.CatID = cat.CatID
GROUP BY Mes, cat.CatNombre
ORDER BY Mes, TotalVentas DESC;

--7. Envíos Pendientes Agrupados por Cliente
SELECT c.ClientesID, c.Clienombre, COUNT(e.EnvioID) AS TotalEnviosPendientes
FROM clientes c
JOIN envio e ON c.ClientesID = e.pedido_ClientesID
WHERE e.En_estado != 'Llegada'
GROUP BY c.ClientesID
HAVING TotalEnviosPendientes > 0;

--8. Resumen de Envíos por Estado y Método de Envío
SELECT e.metodo_En, e.En_estado, COUNT(e.EnvioID) AS TotalEnvios
FROM envio e
GROUP BY e.metodo_En, e.En_estado;

--9. Cantidad de Productos por Categoría y Estado
SELECT cat.CatNombre, p.Prodestado, COUNT(p.ProdID) AS TotalProductos
FROM categoria cat
JOIN productos p ON cat.CatID = p.CatID
GROUP BY cat.CatID, p.Prodestado;

--10.Productos sin Ventas en el Último Año
SELECT p.ProdNombre 
FROM productos p
WHERE p.Prodestado = 'Activo' AND 
    (SELECT COUNT(*)
     FROM detalle_pedido dp
     JOIN pedido pd ON dp.PedidoID = pd.PedidoID
     WHERE dp.ProdID = p.ProdID AND pd.Pedfecha >= DATE_SUB(NOW(), INTERVAL 1 YEAR)) = 0;
