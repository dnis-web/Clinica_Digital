<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Agenda de citas - Clínica Digital</title>
</head>
<body>
    <p>
        Hola, {{ session('usuario_nombre') }} ({{ session('usuario_rol') }}) |
        <a href="/pacientes/crear">Registrar paciente</a> |
        <a href="/citas/crear">Agendar cita</a> |
        <a href="/logout">Cerrar sesión</a>
    </p>

    <h1>Agenda de citas</h1>

    @if (session('status'))
        <p style="color:green">{{ session('status') }}</p>
    @endif

    <table border="1" cellpadding="6">
        <thead>
            <tr>
                <th>Fecha</th>
                <th>Hora</th>
                <th>Paciente</th>
                <th>Médico</th>
                <th>Estado</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($citas as $cita)
                <tr>
                    <td>{{ $cita->fecha_cita }}</td>
                    <td>{{ $cita->hora_inicio }} - {{ $cita->hora_fin }}</td>
                    <td>{{ $cita->paciente }}</td>
                    <td>{{ $cita->medico }}</td>
                    <td>{{ $cita->estado_cita }}</td>
                </tr>
            @empty
                <tr><td colspan="5">Aún no hay citas agendadas.</td></tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
