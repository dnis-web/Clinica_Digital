<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Clinica extends Model
{
    protected $table = 'clinica';
    protected $primaryKey = 'id_clinica';
    public $timestamps = false;

    protected $fillable = ['nombre', 'direccion', 'telefono', 'correo', 'id_plan'];

    public function plan()
    {
        return $this->belongsTo(PlanSuscripcion::class, 'id_plan', 'id_plan');
    }
}
