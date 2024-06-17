<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    public function index(){
        DB::connection()->enableQueryLog();
        $users = User::all();
        $queries = DB::getQueryLog();

        dd($queries);
        return $users;
    }

    public function store(){
        DB::connection()->enableQueryLog();
        $user['name'] = 'Josh';
        $user['password'] = bcrypt('password');
        $user['email'] = 'asiedukevin050@gmail.com';
        User::create($user);
        $queries = DB::getQueryLog();

        dd($queries);
        return $user;
    }
}
