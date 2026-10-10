<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_la_raiz_redirige_al_login(): void
    {
        $this->get('/')->assertRedirect('/login');
    }

    public function test_el_login_responde_correctamente(): void
    {
        $this->get('/login')->assertStatus(200);
    }

    public function test_citas_sin_sesion_redirige_al_login(): void
    {
        $this->get('/citas')->assertRedirect('/login');
    }
}
