package foundation.util;

public final class Clock {
    private Clock() {}
    public static long nowMillis() {
        return System.currentTimeMillis();
    }
}
