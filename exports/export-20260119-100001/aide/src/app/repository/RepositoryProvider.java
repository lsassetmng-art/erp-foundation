package app.repository;

public final class RepositoryProvider {

    private RepositoryProvider() {}

    @SuppressWarnings("unchecked")
    public static <T> T provide(Class<T> clazz) {
        try {
            String implName = clazz.getName() + "Impl";
            Class<?> impl = Class.forName(implName.replace(".repository.", ".repository.impl."));
            return (T) impl.getDeclaredConstructor().newInstance();
        } catch (Exception e) {
            throw new IllegalStateException("Repository resolve failed", e);
        }
    }
}
