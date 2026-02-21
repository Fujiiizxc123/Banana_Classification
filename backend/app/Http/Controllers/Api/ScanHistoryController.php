<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScanHistory;
use Illuminate\Http\Request;

class ScanHistoryController extends Controller
{
    public function index(Request $request)
    {
        $history = ScanHistory::where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json($history);
    }

    public function store(Request $request)
    {
        $request->validate([
            'result'     => 'required|string',
            'confidence' => 'required|numeric',
        ]);

        $history = ScanHistory::create([
            'user_id'    => $request->user()->id,
            'result'     => $request->result,
            'confidence' => $request->confidence,
            'image_path' => $request->image_path ?? null,
        ]);

        return response()->json($history, 201);
    }

    public function destroy($id, Request $request)
    {
        $history = ScanHistory::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $history->delete();

        return response()->json(['message' => 'Deleted successfully']);
    }
}