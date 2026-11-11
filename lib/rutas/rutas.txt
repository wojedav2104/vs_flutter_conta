/// Constantes nombradas de las rutas utilizadas en la aplicación.
abstract final class ClaseRutas {

  // ── Archivos ────────────────────────────────────────────────────────────
  static const String rutaAsientos               = '/archivos/asientos';
  static const String rutaCompras                = '/archivos/compras';
  static const String rutaCuentas                = '/archivos/cuentas';
  static const String rutaRetencionesClientes    = '/archivos/retenciones_clientes';
  static const String rutaRetencionesProveedores = '/archivos/retenciones_proveedores';
  static const String rutaVentas                 = '/archivos/ventas';

  // ── Tablas ──────────────────────────────────────────────────────────────
  static const String rutaClientes             = '/tablas/clientes';
  static const String rutaConfiguracion        = '/tablas/configuracion';
  static const String rutaCuentasAsignadas     = '/tablas/cuentas_asignadas';
  static const String rutaEmpresa              = '/tablas/empresa';
  static const String rutaProveedores          = '/tablas/proveedores';
  static const String rutaSucursales           = '/tablas/sucursales';
  static const String rutaTimbradosPropios     = '/tablas/timbrados_propios';
  static const String rutaTimbradosProveedores = '/tablas/timbrados_proveedores';

  // ── Procesos ────────────────────────────────────────────────────────────
  static const String rutaCierreAnual         = '/procesos/cierre_anual';
  static const String rutaMarangatu           = '/procesos/marangatu';
  static const String rutaReaperturaCuentas   = '/procesos/reapertura_cuentas';
  static const String rutaReorganizarAsientos = '/procesos/reorganizar_asientos';

  // ── Informes ────────────────────────────────────────────────────────────
  static const String rutaBalanceGeneral     = '/informes/balance_general';
  static const String rutaBalanceSumasSaldos = '/informes/balance_sumas_saldos';
  static const String rutaEstadoResultados   = '/informes/estado_resultados';
  static const String rutaLibroDiario        = '/informes/libro_diario';
  static const String rutaLibroMayor         = '/informes/libro_mayor';
  static const String rutaPlanCuentas        = '/informes/plan_cuentas';
  static const String rutaVerificacionDatos  = '/informes/verificacion_datos';

  // ── Utilitarios ─────────────────────────────────────────────────────────
  static const String rutaUsuarios = '/utilitarios/usuarios';

  // ── Sistema ─────────────────────────────────────────────────────────────
  static const String rutaBasesDatos = '/sistema/bases_datos';
  
}