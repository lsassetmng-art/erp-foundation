package app.domain.exception;

public final class ConflictException extends DomainException {
    public ConflictException(String message) {
        super(message);
    }
}
