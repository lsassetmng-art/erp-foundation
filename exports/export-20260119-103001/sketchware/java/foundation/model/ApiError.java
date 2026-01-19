package foundation.model;

/** Minimal error model for logging/diagnostics */
public final class ApiError {
    public final String message;
    public final String detail;

    public ApiError(String message, String detail) {
        this.message = message;
        this.detail = detail;
    }
}
