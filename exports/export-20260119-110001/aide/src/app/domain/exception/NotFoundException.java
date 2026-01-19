package app.domain.exception;

public final class NotFoundException extends DomainException {
    public NotFoundException(String message) {
        super(message);
    }
}
