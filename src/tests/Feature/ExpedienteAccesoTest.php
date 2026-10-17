<?php

namespace Tests\Feature;

use App\Models\Paciente;
use Tests\TestCase;

/**
 * Pruebas de control de acceso del módulo de expedientes.
 * Recepción ve datos básicos; solo Administrador y Médico acceden a lo clínico.
 */
class ExpedienteAccesoTest extends TestCase
{
    private function sesion(string $rol): array
    {
        return ['usuario_id' => 99, 'usuario_nombre' => 'Prueba', 'usuario_rol' => $rol];
    }

    public function test_pacientes_sin_sesion_redirige_al_login(): void
    {
        $this->get('/pacientes')->assertRedirect('/login');
    }

    public function test_recepcion_puede_listar_pacientes(): void
    {
        $this->withSession($this->sesion('Recepción'))->get('/pacientes')->assertStatus(200);
    }

    public function test_recepcion_no_puede_registrar_consultas(): void
    {
        $this->withSession($this->sesion('Recepción'))->get('/citas/1/consulta')->assertStatus(403);
        $this->withSession($this->sesion('Recepción'))->post('/citas/1/consulta', ['diagnostico' => 'x'])->assertStatus(403);
    }

    public function test_recepcion_no_ve_historial_clinico(): void
    {
        $paciente = Paciente::first();
        $this->assertNotNull($paciente, 'Debe existir al menos un paciente de prueba.');

        $this->withSession($this->sesion('Recepción'))
            ->get('/pacientes/'.$paciente->id_paciente)
            ->assertStatus(200)
            ->assertSee('Información clínica restringida');
    }

    public function test_administrador_puede_listar_pacientes(): void
    {
        $this->withSession($this->sesion('Administrador'))->get('/pacientes')->assertStatus(200);
    }
}
