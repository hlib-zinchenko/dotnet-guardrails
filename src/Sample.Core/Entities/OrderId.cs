namespace Sample.Core.Entities;

public readonly record struct OrderId(Guid Value) : IEntityId;
