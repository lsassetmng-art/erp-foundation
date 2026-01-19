package foundation.guard;

public final class Preconditions {

    private Preconditions() {}

    public static void notEmpty(String v, String name) {
        if (v == null || v.isEmpty()) {
            throw new IllegalArgumentException(name + " must not be empty");
        }
    }

    public static void state(boolean ok, String message) {
        if (!ok) throw new IllegalStateException(message);
    }
}
