<?php

namespace App\Http\Controllers;

class PageController extends Controller
{
    public function welcome()
    {
        return view('welcome');
    }

    public function settings()
    {
        return view('pages.settings');
    }

    public function about()
    {
        return view('pages.about');
    }

    public function faqs()
    {
        return view('pages.faqs');
    }
}
