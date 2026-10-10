<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('titulo', 'Clínica Digital')</title>
    <link rel="stylesheet" href="/css/clinica.css">
</head>
<body>
<aside class="sidebar">
    <div class="logo-sistema">
        <div class="logo-pequeno">+</div>
        <h2>Clínica Digital</h2>
    </div>

    <a href="/citas" class="{{ request()->is('citas') ? 'active' : '' }}">📅 Agenda de citas</a>
    <a href="/citas/crear" class="{{ request()->is('citas/crear') ? 'active' : '' }}">➕ Agendar cita</a>
    <a href="/pacientes/crear" class="{{ request()->is('pacientes/crear') ? 'active' : '' }}">👤 Registrar paciente</a>

    <span class="menu-off">🩺 Médicos <small>Próximamente</small></span>
    <span class="menu-off">📁 Expedientes <small>Próximamente</small></span>
    <span class="menu-off">💳 Pagos <small>Próximamente</small></span>
    <span class="menu-off">🔔 Notificaciones <small>Próximamente</small></span>

    <div class="grow"></div>

    <form method="POST" action="/logout">
        @csrf
        <button type="submit" class="menu-btn">🚪 Cerrar sesión</button>
    </form>
</aside>

<main class="contenido">
    <div class="header">
        <div>
            <h1>@yield('encabezado')</h1>
            <p>@yield('subtitulo')</p>
        </div>
        <div class="usuario">👤 {{ session('usuario_nombre') }} · {{ session('usuario_rol') }}</div>
    </div>

    @if (session('status'))
        <div class="alert alert-ok">{{ session('status') }}</div>
    @endif

    @if ($errors->any())
        <div class="alert alert-error">
            @foreach ($errors->all() as $error)
                <p>{{ $error }}</p>
            @endforeach
        </div>
    @endif

    @yield('contenido')
</main>
</body>
</html>
