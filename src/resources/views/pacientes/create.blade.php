<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registrar paciente - Clínica Digital</title>
</head>
<body>
    <p><a href="/citas">← Ver agenda</a> | <a href="/logout">Cerrar sesión</a></p>

    <h1>Registrar paciente</h1>

    @if ($errors->any())
        <div style="color:red">
            @foreach ($errors->all() as $error)
                <p>{{ $error }}</p>
            @endforeach
        </div>
    @endif

    <form method="POST" action="/pacientes">
        @csrf
        <label>DPI:</label><br>
        <input type="text" name="dpi" value="{{ old('dpi') }}" required><br><br>

        <label>Nombres:</label><br>
        <input type="text" name="nombres" value="{{ old('nombres') }}" required><br><br>

        <label>Apellidos:</label><br>
        <input type="text" name="apellidos" value="{{ old('apellidos') }}" required><br><br>

        <label>Fecha de nacimiento:</label><br>
        <input type="date" name="fecha_nacimiento" value="{{ old('fecha_nacimiento') }}" required><br><br>

        <label>Sexo:</label><br>
        <select name="sexo" required>
            <option value="">-- Selecciona --</option>
            <option value="M">Masculino</option>
            <option value="F">Femenino</option>
        </select><br><br>

        <label>Teléfono:</label><br>
        <input type="text" name="telefono" value="{{ old('telefono') }}"><br><br>

        <label>Correo:</label><br>
        <input type="email" name="correo" value="{{ old('correo') }}"><br><br>

        <label>Dirección:</label><br>
        <input type="text" name="direccion" value="{{ old('direccion') }}"><br><br>

        <button type="submit">Registrar paciente</button>
    </form>
</body>
</html>
