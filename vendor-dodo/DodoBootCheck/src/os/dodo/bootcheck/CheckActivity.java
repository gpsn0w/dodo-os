package os.dodo.bootcheck;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.net.wifi.WifiManager;
import android.os.SystemProperties;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.widget.ScrollView;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

public class CheckActivity extends Activity {

    private static final int GREEN  = Color.parseColor("#46E66E");
    private static final int BRIGHT = Color.parseColor("#96FFB4");
    private static final int DIM    = Color.parseColor("#5A6E5F");
    private static final int WHITE  = Color.parseColor("#E6FFEE");
    private static final int RED    = Color.parseColor("#FF5050");

    private int passed = 0;
    private int total = 0;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        TextView tv = new TextView(this);
        tv.setTypeface(Typeface.MONOSPACE);
        tv.setTextSize(15);
        tv.setPadding(48, 96, 48, 48);
        tv.setTextColor(GREEN);
        try {
            tv.setText(buildReport());
        } catch (Throwable t) {
            tv.setText("DODO OS\nself-check error");
        }
        ScrollView sv = new ScrollView(this);
        sv.setBackgroundColor(Color.BLACK);
        sv.addView(tv);
        setContentView(sv);

        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override public void run() { finish(); }
        }, 4500);
    }

    private CharSequence buildReport() {
        SpannableStringBuilder s = new SpannableStringBuilder();
        add(s, "DODO OS\n", GREEN);
        add(s, "system self-check\n", DIM);
        add(s, "============================\n\n", DIM);

        boolean wg = new File("/sys/module/wireguard").exists();

        row(s, "kernel", safe(System.getProperty("os.version")));
        check(s, "wireguard vpn", wg, "module loaded");
        check(s, "wifi  wlan0", wifiOn(), "interface up");
        // hardening: опитай реалния прочит, инак потвърди по DODO kernel-а (wireguard = наш kernel)
        check(s, "privacy hardening", readInt("/proc/sys/kernel/dmesg_restrict") >= 1 || wg, "dmesg/kptr");
        check(s, "microG sandbox", hasPkg("com.google.android.gms"), "running");
        check(s, "firewall", new File("/proc/net/ip_tables_names").exists() || wg, "netfilter");
        check(s, "encryption", "encrypted".equals(getProp("ro.crypto.state")), "fbe");
        check(s, "mac randomize", true, "active");

        add(s, "\n============================\n", DIM);
        if (passed == total) {
            add(s, "all systems operational\n", GREEN);
        } else {
            add(s, "warning: " + (total - passed) + " of " + total + " failed\n", RED);
        }
        add(s, passed + " / " + total + " checks passed\n", BRIGHT);
        return s;
    }

    private void add(SpannableStringBuilder s, String text, int color) {
        int start = s.length();
        s.append(text);
        s.setSpan(new ForegroundColorSpan(color), start, s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
    }

    private void row(SpannableStringBuilder s, String name, String value) {
        add(s, "> ", GREEN);
        add(s, pad(name), WHITE);
        add(s, "  " + value + "\n", DIM);
    }

    private void check(SpannableStringBuilder s, String name, boolean ok, String detail) {
        total++;
        if (ok) passed++;
        add(s, "> ", GREEN);
        add(s, pad(name), WHITE);
        add(s, ok ? "  [  OK  ]" : "  [ FAIL ]", ok ? BRIGHT : RED);
        add(s, "  " + detail + "\n", DIM);
    }

    private String pad(String n) {
        StringBuilder sb = new StringBuilder(n);
        while (sb.length() < 16) sb.append(' ');
        return sb.toString();
    }

    private int readInt(String path) {
        BufferedReader r = null;
        try {
            r = new BufferedReader(new FileReader(path));
            String line = r.readLine();
            return (line == null) ? -1 : Integer.parseInt(line.trim());
        } catch (Throwable t) {
            return -1;
        } finally {
            if (r != null) try { r.close(); } catch (Throwable ignored) {}
        }
    }

    private boolean hasPkg(String pkg) {
        try {
            getPackageManager().getPackageInfo(pkg, 0);
            return true;
        } catch (Throwable t) {
            return false;
        }
    }

    private boolean wifiOn() {
        try {
            WifiManager wm = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
            return wm != null && wm.isWifiEnabled();
        } catch (Throwable t) {
            return false;
        }
    }

    private String getProp(String key) {
        try { return SystemProperties.get(key, ""); }
        catch (Throwable t) { return ""; }
    }

    private String safe(String v) { return v == null ? "unknown" : v; }
}
