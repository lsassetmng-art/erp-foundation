package foundation.repo;

import foundation.session.SessionGuard;
import foundation.supabase.SupabaseClient;

/**
 * BaseRepository
 * - Enforces session initialized
 * - Does NOT expose company_id (RLS assumed)
 */
public abstract class BaseRepository {

    protected final SupabaseClient client;

    protected BaseRepository(SupabaseClient client) {
        this.client = client;
        SessionGuard.requireInitialized();
    }
}
