package com.example.helloandroid;

import android.app.Activity;
import android.os.Bundle;
import android.view.MotionEvent;

import android.content.Intent;
import android.net.Uri;
import android.widget.Button;
import android.view.View;
import android.view.View.OnClickListener;

public class MainActivity extends Activity {
	static {
		try{
			System.loadLibrary("esm_model");
		} catch (UnsatisfiedLinkError e){
			System.err.println("libesm_model failed to load: " + e);
			System.exit(1);
		}
	}

	private static native int my_ESM_register();
	private static native int my_ESM_wait();

	Button button;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		addListenerOnButton();
	}

	public void addListenerOnButton() {
		button = (Button) findViewById(R.id.button1);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				my_ESM_register();
			}
		});

		button = (Button) findViewById(R.id.button2);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				my_ESM_wait();
			}
		});

		button = (Button) findViewById(R.id.button3);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				my_ESM_register();
				my_ESM_wait();
			}
		});
	}
}
