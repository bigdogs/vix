use anyhow::Result;

pub struct DirectoryEntry {
    pub path: String,
}

pub fn list_directory(folder: String) -> Result<Vec<DirectoryEntry>> {
    unimplemented!()
}
