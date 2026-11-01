namespace Sample.Core.Time;

/// <summary>
/// The only way to read the current time: <c>DateTime.UtcNow</c> and friends are banned
/// (see <c>BannedSymbols.txt</c>) so time stays injectable and testable.
/// </summary>
public interface IClock
{
    DateTimeOffset UtcNow { get; }
}
