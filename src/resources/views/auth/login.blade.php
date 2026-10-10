<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión - Clínica Digital</title>
    <link rel="stylesheet" href="/css/clinica.css">
</head>
<body>
<div class="login-wrap">
    <div class="login-card">
        <div class="logo-login">
            <div class="logo-icono">+</div>
            <h1>Clínica Digital</h1>
            <p>Sistema de gestión clínica</p>
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

        <form method="POST" action="/login">
            @csrf
            <div class="form-group">
                <label for="correo">Correo electrónico</label>
                <input id="correo" type="email" name="correo" value="{{ old('correo') }}" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">Contraseña</label>
                <input id="password" type="password" name="password" required autocomplete="current-password">
            </div>
            <button type="submit" class="btn-login">Iniciar sesión</button>
        </form>

        <p class="demo-text">Seminario de Tecnología de Información · UMG</p>
    </div>
</div>
</body>
</html>
