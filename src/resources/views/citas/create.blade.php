<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Agendar cita - Clínica Digital</title>
</head>
<body>
    <p><a href="/citas">← Ver agenda</a> | <a href="/pacientes/crear">Registrar paciente</a> | <a href="/logout">Cerrar sesión</a></p>

    <h1>Agendar cita</h1>

    @if ($errors->any())
        <div style="color:red">
            @foreach ($errors->all() as $error)
                <p>{{ $error }}</p>
            @endforeach
        </div>
    @endif

    <form method="POST" action="/citas">
        @csrf
        <label>Paciente:</label><br>
        <select name="id_paciente" required>
            <option value="">-- Selecciona --</option>
            @foreach ($pacientes as $p)
                <option value="{{ $p->id_paciente }}">{{ $p->nombres }} {{ $p->apellidos }} (DPI {{ $p->dpi }})</option>
            @endforeach
        </select><br><br>

        <label>Médico:</label><br>
        <select name="id_medico" required>
            <option value="">-- Selecciona --</option>
            @foreach ($medicos as $m)
                <option value="{{ $m->id_medico }}">{{ $m->nombres }} {{ $m->apellidos }} — {{ $m->especialidad }}</option>
            @endforeach
        </select><br><br>

        <label>Fecha:</label><br>
        <input type="date" name="fecha" value="{{ old('fecha') }}" required><br><br>

        <label>Hora inicio:</label><br>
        <input type="time" name="hora_inicio" value="{{ old('hora_inicio') }}" required><br><br>

        <label>Hora fin:</label><br>
        <input type="time" name="hora_fin" value="{{ old('hora_fin') }}" required><br><br>

        <label>Motivo:</label><br>
        <input type="text" name="motivo" value="{{ old('motivo') }}"><br><br>

        <button type="submit">Agendar cita</button>
    </form>
</body>
</html>
