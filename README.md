# 🏦 End-to-End Data Pipeline: Automatización de Conciliación Bancaria

## 📊 Sobre el Proyecto
Este proyecto es una solución integral de **Business Intelligence y automatización** diseñada para resolver uno de los cuellos de botella más comunes en la administración financiera: la conciliación bancaria manual. 

El pipeline extrae extractos bancarios crudos, los limpia, los procesa en un motor relacional y los cruza automáticamente con los registros contables, entregando las "partidas conciliatorias" (diferencias) listas para su análisis en una interfaz visual.

## 🛠️ Stack Tecnológico
* **Lenguaje de Programación:** Python (Pandas, SQLAlchemy) para el proceso ETL de limpieza e ingesta.
* **Base de Datos:** MySQL (Modelado de datos, JOINs, Views, Anti-JOINs).
* **Visualización & Reporting:** Excel / Power Query (Conexión directa a vistas SQL mediante ODBC).

## 🚀 Arquitectura del Flujo de Datos (ETL)
1. **Extract:** Lectura de archivos `.csv` crudos simulando la exportación de un Home Banking argentino (con metadatos y suciedad).
2. **Transform:** Limpieza de datos con Python (eliminación de caracteres especiales en importes mediante Regex, normalización de fechas, y estandarización de columnas).
3. **Load:** Ingesta automatizada de los datos limpios en una base de datos relacional MySQL normalizada.
4. **Data Modeling (SQL):** Creación de vistas analíticas para detectar coincidencias perfectas y aislar partidas pendientes (SIRCREB, Impuesto al Cheque, comisiones, cheques no debitados).

## 💡 Valor Agregado al Negocio
* **Reducción de tiempos:** Elimina el "punteo" manual línea por línea.
* **Integridad de datos:** Evita errores de tipeo humano al trasladar cifras.
* **Trazabilidad:** Separa claramente las transacciones pendientes del libro de las transacciones no registradas por la empresa.

## 👨‍💼 Sobre Mí
Soy Tomás, Contador Público (UBA) apasionado por el Análisis de Datos. Combino mi profundo conocimiento del dominio contable, impositivo y financiero con herramientas tecnológicas (Python, SQL, Power BI) para transformar datos crudos en decisiones de negocio ágiles y precisas. 

Conectá conmigo en [LinkedIn](www.linkedin.com/in/tomas-encina-217395202).
