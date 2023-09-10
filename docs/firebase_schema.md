# Firestore Database Schema

## Collections

### Users Collection
- DocumentID (Firebase Auth ID)
  - email: String

### Projects Collection
- DocumentID (Auto-generated)
  - name: String
  - created_at: Timestamp
  - created_by: Reference (Users DocumentID)
  - owners: Array (References to Users DocumentIDs)

### Songs Collection
- DocumentID (Auto-generated)
  - created_at: Timestamp
  - title: String
  - project_id: Reference (Projects DocumentID)
  - state: String ('draft', 'demo', 'final_version')
  - versions (Sub-collection)
    - DocumentID: (Auto-generated)
      - version_number: Int
      - timestamp: String (ISO 8601)
      - file: 
        - original_name: String
        - storage_name: String
        - size: Int
        - duration: Tnt
        - mime_type: String
        - download_url: String

### Versions Collection
- DocumentID (Auto-generated)
  - song_id: Reference (Songs DocumentID)
  - version_number: String
  - lyrics: String
  - timestamp: Timestamp
  - file: Map
    - name: String
    - size: Int
    - duration: Int
    - mime_type: String
    - download_url: String

---

# Firebase Storage Schema

## File Naming Convention
- ```{projectId}_{songId}_{versionNumber}.mp3```

## Example
- proj_123_song_456_1.mp3
- proj_123_song_456_2.mp3
