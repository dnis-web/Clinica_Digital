<?php

namespace Tests\Feature;

use App\Models\Medico;
use App\Models\Paciente;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

/**
 * Nota importante: como la base de datos se construye con los scripts SQL
 * del equipo (triggers, procedimientos) y no con migraciones de Laravel,
 * NO se usa el trait RefreshDatabase aquí (borraría esos objetos). Estas
 * pruebas deben correr contra una base de datos de PRUEBA ya inicializada
 * con clinica_digital_mysql.sql + al menos un paciente y un médico de
 * ejemplo (ver pruebas_clinica_digital.sql). Configura DB_DATABASE en
 * phpunit.xml apuntando a esa base de datos de pruebas, separada de la
 * de desarrollo, para no ensuciar los datos reales con cada ejecución.
 */
class AgendarCitaTest extends TestCase
{
    /**
     * CP-01: el sistema debe rechazar una cita cuyo horario se traslapa
     * con una cita ya existente del mismo médico (regla de negocio RN01,
     * aplicada mediante trigger en la base de datos).
     */
    public function test_rechaza_cita_con_horario_solapado(): void
    {
        $paciente = Paciente::first();
        $medico = Medico::first();

        $this->assertNotNull($paciente, 'Debe existir al menos un paciente de prueba.');
        $this->assertNotNull($medico, 'Debe existir al menos un médico de prueba.');

        $fecha = now()->addDay()->toDateString();

        // Primera cita: debe agendarse sin problema.
        DB::select('CALL sp_agendar_cita(?, ?, ?, ?, ?, ?)', [
            $paciente->id_paciente, $medico->id_medico, $fecha, '09:00:00', '09:30:00', 'Consulta 1',
        ]);

        // Segunda cita: se traslapa con la anterior (09:10 - 09:40).
        $this->expectException(\Illuminate\Database\QueryException::class);

        DB::select('CALL sp_agendar_cita(?, ?, ?, ?, ?, ?)', [
            $paciente->id_paciente, $medico->id_medico, $fecha, '09:10:00', '09:40:00', 'Consulta 2 (debe rechazarse)',
        ]);
    }

    /**
     * CP-02: una cita en un horario distinto, sin traslape, sí debe
     * agendarse correctamente.
     */
    public function test_permite_cita_en_horario_disponible(): void
    {
        $paciente = Paciente::first();
        $medico = Medico::first();
        $fecha = now()->addDays(2)->toDateString();

        DB::select('CALL sp_agendar_cita(?, ?, ?, ?, ?, ?)', [
            $paciente->id_paciente, $medico->id_medico, $fecha, '10:00:00', '10:30:00', 'Consulta de control',
        ]);

        $this->assertDatabaseHas('cita', [
            'id_paciente' => $paciente->id_paciente,
            'id_medico' => $medico->id_medico,
            'fecha_cita' => $fecha,
        ]);
    }
}
