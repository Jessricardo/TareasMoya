/*
Tarea numero 1
Apodaca Atondo Jesús Ricardo

create database Tarea_1
use Tarea_1
create table Movimientos(
	[Actor] NVARCHAR(50) NOT NULL,
	[FechaTransicion] DATETIME NOT NULL,
	[PerfilId] UNIQUEIDENTIFIER NOT NULL,
	[Version] INT NOT NULL,
	[Nombre] NVARCHAR(50) NOT NULL,
	[Nivel] INT NOT NULL
)
create table Perfiles(
	Vendedor NVARCHAR(50) NOT NULL,
	Creado DATETIME NOT NULL,
	[PerfilId] UNIQUEIDENTIFIER NOT NULL,
	Nombre  NVARCHAR(50) NOT NULL,
	[Nivel] INT NOT NULL
)
*/
--Aqui se muestra cuantos perfiles tuvo cada vendedor y su tipo actual

select tablaX.Vendedor, tablaX.lastDate, tablaX.numberPerfiles, tablaY.Nombre
from(select Vendedor, max(Creado) lastDate, count(PerfilId) numberPerfiles from dbo.Perfiles group by Vendedor) tablaX
inner join 
(select vendedor, Nombre from Perfiles 
where Creado in (select max(Creado) lastDate 
from dbo.Perfiles 
group by Vendedor)) tablaY
on tablaX.Vendedor= tablaY.Vendedor

--A continuación se calcula el numero de perfiles y asi mismo el nivel que tuvieron los vendedores por mes (solo incluye movimientos o perfiles generados en el mes)

select tablaX.Vendedor, 
count(PerfilId) numberPerfiles,
sum(case when nivel=0 then 1 else 0 end) Nivel_0,
sum(case when nivel=1 then 1 else 0 end) Nivel_1,
sum(case when nivel=2 then 1 else 0 end) Nivel_2,
sum(case when nivel=3 then 1 else 0 end) Nivel_3
from (select Vendedor, PerfilId, Creado, Nivel from Perfiles where Creado between '2016-02-01' and '2016-02-28')
GROUP BY tablaX.Vendedor

--Filtro de todos los perfiles que no empiecen en nivel 3 de la tabla movimientos
select PerfilId, min(FechaTransicion) as [Fecha Inicio] from Movimientos where Nivel !=3 group by PerfilId


--Factores de conversion por mes p/vendedor entre los niveles 3-1, 2-1 y 3-2
select tablaY.Actor, tablaY.Prospecto, tablaY.[Visita Directa], tablaY.Descartado, tablaY.Cliente,
(tablaY.[Visita Directa]+tablaY.Prospecto+tablaY.Descartado+tablaY.Cliente) as Total,
((tablaY.[Visita Directa] * 100)/(tablaY.Prospecto+1)) as [Factor C de Prospecto a Visita Directa],
((tablaY.Cliente * 100)/(tablaY.[Visita Directa]+1)) as [Factor C de Visita Directa a Cliente],
((tablaY.Cliente * 100)/(tablaY.Prospecto+1)) as [Factor C de Prospecto a Cliente]
 from ((select * from
 (select Actor, Nivel, Nombre from Movimientos where FechaTransicion between '2016-02-01' and '2016-02-28') 
 as tablaX
 pivot(count(Nivel) for Nombre in ([Visita Directa],[Prospecto],[Descartado],[Cliente])) p))  as tablaY
 