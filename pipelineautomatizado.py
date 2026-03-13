import pandas as pd 
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()

ruta_archivo = 'extracto_banco_marzo.csv'
df = pd.read_csv(ruta_archivo, skiprows=3, sep=';', encoding='latin1')

df = df.rename(columns={
    'Fecha': 'fecha_banco',
    'Concepto': 'descripcion_banco',
    'Importe': 'monto_banco',
    'Referencia': 'nro_referencia'
})

df['fecha_banco'] = pd.to_datetime(df['fecha_banco'], format='%d/%m/%Y').dt.date

df['monto_banco'] = df['monto_banco'].replace({r'\$': '', ',': ''}, regex=True).astype(float)

df['id_cuenta'] = 2
df['estado_conciliacion'] = 'pendiente'

columnas_finales = ['id_cuenta', 'fecha_banco', 'descripcion_banco', 'monto_banco', 'nro_referencia', 'estado_conciliacion']

df_limpio = df[columnas_finales]

cadena_conexion = os.getenv('DB_CONEXION')
motor = create_engine(cadena_conexion)

try:
    df_limpio.to_sql('fact_extracto_bancario', con=motor, if_exists='append', index=False)
    print("¡Exito! Los movimientos bancarios se cargaron correctamente en SQL.")
except Exception as e:
    print(f"Ocurrió un error al cargar los datos: {e}")
    