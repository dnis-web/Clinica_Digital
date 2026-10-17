<?php

namespace Tests\Feature;

use Tests\TestCase;

/**
 * Pruebas de control de acceso por rol (RBAC) del módulo de médicos.
 */
class MedicoAccesoTest extends TestCase
{
    public function test_medicos_sin_sesion_redirige_al_login(): void
    {
        $this->get('/medicos')->assertRedirect('/login');
    }

    public function test_recepcion_no_puede_ver_medicos(): void
    {
        $this->withSession(['usuario_id' => 99, 'usuario_nombre' => 'Prueba', 'usuario_rol' => 'Recepción'])
            ->get('/medicos')
            ->assertStatus(403);
    }

    public function test_recepcion_no_puede_crear_medicos(): void
    {
        $this->withSession(['usuario_id' => 99, 'usuario_nombre' => 'Prueba', 'usuario_rol' => 'Recepción'])
            ->get('/medicos/crear')
            ->assertStatus(403);
    }

    public function test_administrador_puede_ver_medicos(): void
    {
        $this->withSession(['usuario_id' => 1, 'usuario_nombre' => 'Admin', 'usuario_rol' => 'Administrador'])
            ->get('/medicos')
            ->assertStatus(200);
    }
}
