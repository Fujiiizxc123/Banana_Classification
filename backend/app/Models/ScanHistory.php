<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ScanHistory extends Model
{
    protected $fillable = ['user_id', 'image_path', 'result', 'confidence'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}