USE [TimacaSis]
GO
/****** Object:  StoredProcedure [dbo].[SPConsultaGl]    Script Date: 20/08/2025 10:32:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--set dateformat mdy exec SPConsultaGl '01/01/2021','08/19/2025'
CREATE OR ALTER PROC [dbo].[SPConsultaGl](@desde smalldatetime,@hasta smalldatetime)
as

SELECT r.numero,fecharequisicion,r.descripcion motivo,material,d.descripcion,isnull(CuentaAux,'') CuentaAux,r.motivo descta,

isnull(convert(varchar(10),fechaaprobacionGte,103),'            ') fechaaprobacionGte,isnull(convert(varchar(10),FechaAsignada,103),'            ') FechaAsignada,
comprador,d.OC,'            ' fechaoc,
'                          ' proveedor,r.motivo nombreproveedor,'            ' conformada,'           ' aprobada,
'          ' pagada,'          ' fechallegada,'           ' fecharecepcion,r.estatus into #t1
  FROM  REQUISICION R,DETALLEREQUISICION D WHERE R.NUMERO=D.NUMERO
AND  fecharequisicion between @desde and @hasta --and r.estatus <>'ANU' AND D.ESTATUS <>'ANU'

--select * from #t1


update #t1 set proveedor=o.Proveedor,fechaoc=convert(varchar(10),o.Fecha,103),
aprobada=isnull(convert(varchar(10),o.FechaAprobada,103),''),
conformada=isnull(convert(varchar(10),o.Fechaconformada,103),''),
comprador=nombrecomprador
from ordenes o where #t1.OC=o.numero

update #t1 set fechallegada=isnull(convert(varchar(10),d.FechaEntrega,103),'') from detalleordenes d 
where oc=d.numero and #t1.material=d.material

update #t1 set fecharecepcion=convert(varchar(10),r.fecha,103) from recepcion r where oc=dctoaso
and r.estatus='FI'

update #t1 set descta=nombre from CuentasAux r where #t1.CuentaAux=r.CtaAux
update #t1 set descta='' WHERE DESCTA IS NULL

update #t1 set descta=''  where CuentaAux=''

update #t1 set nombreproveedor=p.Nombre from proveedores p where #t1.proveedor=p.RIF
update #t1 set oc='' WHERE oc IS NULL
update #t1 set nombreproveedor='' WHERE nombreproveedor IS NULL
update #t1 set comprador='' WHERE comprador IS NULL

select t1.*,isnull(dir1,'') ubicacion 
FROM
    #t1 AS T1
	LEFT JOIN
   proveedores AS P ON T1.PROVEEDOR = P.RIF

   --where NUMERO LIKE '%14394'
 order by fecharequisicion desc,numero desc
