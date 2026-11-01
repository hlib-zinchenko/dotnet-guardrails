namespace Sample.Core.Entities;

public abstract class Entity<TId>
    where TId : struct, IEntityId
{
    protected Entity(TId id)
    {
        Id = id;
    }

    public TId Id { get; }
}
