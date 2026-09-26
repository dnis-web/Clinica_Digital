<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Paciente extends Model
{
    protected $table = 'paciente';
    protected $primaryKey = 'id_paciente';
    public $timestamps = false;

    protected $fillable = [
        'id_clinica', 'id_usuario', 'dpi', 'nombres', 'apellidos', 'fecha_nacimiento',
        'telefono', 'correo', 'direccion', 'sexo', 'estado',
    ];

    public function citas()
    {
        return $this->hasMany(Cita::class, 'id_paciente', 'id_paciente');
    }
}
