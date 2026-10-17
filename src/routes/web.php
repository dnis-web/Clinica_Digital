<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect('/login'));

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CitaController;
use App\Http\Controllers\PacienteController;

/*
|--------------------------------------------------------------------------
| Rutas del flujo mínimo funcional (Sprint 1-2): login, pacientes, citas.
| Agrega este bloque a tu routes/web.php ya existente (no borres la ruta
| "/" que Laravel trae por defecto, puedes dejarla o quitarla).
|--------------------------------------------------------------------------
*/

Route::get('/login', [AuthController::class, 'showLogin']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout']);

Route::middleware('checkauth')->group(function () {
    Route::get('/pacientes/crear', [PacienteController::class, 'create']);
    Route::post('/pacientes', [PacienteController::class, 'store']);

    Route::get('/citas', [CitaController::class, 'index']);
    Route::get('/citas/crear', [CitaController::class, 'create']);
    Route::post('/citas', [CitaController::class, 'store']);
});

Route::middleware(['checkauth', 'checkrol:Administrador'])->group(function () {
    Route::get('/medicos', [\App\Http\Controllers\MedicoController::class, 'index']);
    Route::get('/medicos/crear', [\App\Http\Controllers\MedicoController::class, 'create']);
    Route::post('/medicos', [\App\Http\Controllers\MedicoController::class, 'store']);
    Route::post('/medicos/{id}/estado', [\App\Http\Controllers\MedicoController::class, 'cambiarEstado']);
});
