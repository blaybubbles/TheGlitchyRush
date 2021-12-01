using UnityEngine;
using UnityEngine.AddressableAssets;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// This allows us to store a database of all characters currently in the bundles, indexed by name.
/// </summary>
public class CharacterDatabase
{
    static protected Dictionary<string, CharactersSet> m_CharactersDict;

    static public Dictionary<string, CharactersSet> dictionary {  get { return m_CharactersDict; } }

    static protected bool m_Loaded = false;
    static public bool loaded { get { return m_Loaded; } }

    static public CharactersSet GetCharacter(string type)
    {
        CharactersSet c;
        if (m_CharactersDict == null || !m_CharactersDict.TryGetValue(type, out c))
            return null;

        return c;
    }

    static public IEnumerator LoadDatabase()
    {
        if (m_CharactersDict == null)
        {
            m_CharactersDict = new Dictionary<string, CharactersSet>();

            yield return Addressables.LoadAssetsAsync<GameObject>("charactersSets", op =>
            {
                CharactersSet c = op.GetComponent<CharactersSet>();
                if (c != null)
                {
                    m_CharactersDict.Add(c.characterName, c);
                }
            });

            m_Loaded = true;
        }
    }
}