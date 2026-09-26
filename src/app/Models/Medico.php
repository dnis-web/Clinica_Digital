<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medico extends Model
{
    protected $table = 'medico';
    protected $primaryKey = 'id_medico';
    public $timestamps = false;

    protected $fillable = [
        'id_clinica', 'id_usuario', 'nombres', 'apellidos', 'colegiado',
        'especialidad', 'telefono', 'correo', 'estado',
    ];

    public function citas()
    {
        return $this->hasMany(Cita::class, 'id_medico', 'id_medico');
    }
}
