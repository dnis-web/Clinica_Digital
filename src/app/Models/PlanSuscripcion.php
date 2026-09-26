<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlanSuscripcion extends Model
{
    protected $table = 'plan_suscripcion';
    protected $primaryKey = 'id_plan';
    public $timestamps = false;

    protected $fillable = [
        'nombre_plan', 'limite_pacientes', 'limite_citas_mensuales', 'precio_mensual',
    ];
}
