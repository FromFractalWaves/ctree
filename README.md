# CTree: Tame AI Chaos with Structured Power

**CTree** is a CLI tool designed to transform AI-generated code from sprawl to structure. It’s built to manage complexity, offering a configurable way to snapshot and organize codebases for modular development—ideal for Next.js apps, FastAPI backends, or any AI-driven project.

---

## Why CTree?

AI can produce brilliant but unwieldy code. CTree solves that:
- **Control Complexity**: Extract and organize code for AI input.
- **Scale Smart**: Manage modular updates across files and dirs.
- **Stay in Charge**: Guide AI with precision, not blind trust.

It’s a precision tool for code management, enabling rapid refactoring and scalability.

---

## Installation

```sh
sudo cp ctree.sh /usr/local/bin/ctree
sudo chmod +x /usr/local/bin/ctree
```

---

## Setup

Two config files (create with `touch ~/.ctreeconf ~/.ctreeignore`):

### `~/.ctreeconf` (File Flags)
Map flags to extensions:
```ini
#~/.ctreeconf

[flags]
1 = tsx, ts
2 = tsx, ts, json
3 = tsx, ts, prisma, json, js, py
4 = prisma, json, js, md, mjs
5 = js
6 = txt, md
7 = txt, sh
8 = py
9 = ts, tsx, py
10 = txt, md
```
Customize for your stack.

### `~/.ctreeignore` (Ignore Patterns)
Mimics `.gitignore` for familiarity:
```gitignore
node_modules/
__pycache__/
*.log
```
See `ctreeignore.txt` for more.

---

## Usage

### Basic Tree
Generate a directory tree:
```sh
ctree
```

#### Example Output
```sh
db_api$ ctree
db_api/
├── __init__.py
├── config.py
├── db.py
├── main.py
├── models.py
├── routers/
│   ├── __init__.py
│   ├── content.py
│   ├── content_item.py
│   ├── embedding.py
│   └── processor.py
├── schemas.py
├── sentences_main.py
└── utils.py
```
- Displays a clean hierarchy of the `db_api` directory.

### Extract with Content
Extract file contents with configurable verbosity:
- `-vv`: Include file contents.
- `-vvv`: Include contents with additional details (e.g., comments, full structure).
- All files:
  ```sh
  ctree -vvv -a > project.ctree
  ```
- Targeted dirs:
  ```sh
  cd db_api/routers/
  ctree -8 -vvv > routers.ctree
  ```

#### Example Output
Running `ctree -8 -vvv` in `db_api/routers/` produces:
```sh
routers/
├── __init__.py
│       # db_api/routers/__init__.py
│       
│       from .content import router as content_router
│       from .content_item import router as content_item_router
│       from .processor import router as Processing_router
│       from .embedding import router as embedding_router
│       
│       __all__ = ["content_router", "content_item_router", "processing_router", "embedding_router"]
├── content.py
│       # db_api/routers/content.py
│       import json
│       import logging
│       from typing import Any, Dict, List, Optional
│       
│       from fastapi import APIRouter, HTTPException, Query, Body
│       from db_api.db import get_db
│       from db_api.schemas import Content, ContentCreate, SuccessResponse
│       
│       router = APIRouter(prefix="/content", tags=["Content"])
│       logger = logging.getLogger(__name__)
│       
│       @router.post("", response_model=SuccessResponse)
│       async def create_content(item: ContentCreate):
│           """Create a new content entry."""
│           try:
│               with get_db() as conn:
│                   metadata_json = json.dumps(item.metadata) if item.metadata is not None else None
│                   cursor = conn.execute(
│                       """
│                       INSERT INTO content (type, content, metadata) 
│                       VALUES (?, ?, ?)
│                       RETURNING id, type, content, metadata, created_at
│                       """,
│                       (item.type.strip(), item.content.strip(), metadata_json)
│                   )
│                   result = cursor.fetchone()
│                   conn.commit()
│                   created_item = Content(
│                       id=result["id"],
│                       type=result["type"],
│                       content=result["content"],
│                       metadata=json.loads(result["metadata"]) if result["metadata"] else None,
│                       created_at=result["created_at"]
│                   )
│                   return SuccessResponse(data=created_item)
│           except Exception as e:
│               logger.error(f"Error creating content: {str(e)}")
│               raise HTTPException(status_code=500, detail={"error": "Failed to create content"})
│       # ... (additional endpoints: get, update, delete, stats, batch operations)
├── content_item.py
│       # db_api/routers/content_item.py
│       import json
│       import logging
│       from typing import List
│       
│       from fastapi import APIRouter, HTTPException, Body
│       from db_api.db import get_db
│       from db_api.schemas import ContentItem, ContentItemCreate, ContentItemSuccessResponse
│       
│       router = APIRouter(prefix="/content", tags=["Content Items"])
│       logger = logging.getLogger(__name__)
│       
│       @router.post("/{content_id}/items", response_model=ContentItemSuccessResponse)
│       async def create_content_item(content_id: int, item: ContentItemCreate):
│           """Create a new content item for a specific content entry."""
│           try:
│               with get_db() as conn:
│                   parent_cursor = conn.execute("SELECT id FROM content WHERE id = ?", (content_id,))
│                   if parent_cursor.fetchone() is None:
│                       raise HTTPException(status_code=404, detail="Parent content not found")
│                   metadata_json = json.dumps(item.metadata) if item.metadata is not None else None
│                   cursor = conn.execute(
│                       """
│                       INSERT INTO content_item (content_id, title, body, metadata) 
│                       VALUES (?, ?, ?, ?)
│                       RETURNING id, content_id, title, body, metadata, created_at, updated_at
│                       """,
│                       (content_id, item.title.strip(), item.body.strip(), metadata_json)
│                   )
│                   row = cursor.fetchone()
│                   conn.commit()
│                   created_item = ContentItem(
│                       id=row["id"],
│                       content_id=row["content_id"],
│                       title=row["title"],
│                       body=row["body"],
│                       metadata=json.loads(row["metadata"]) if row["metadata"] else None,
│                       created_at=row["created_at"],
│                       updated_at=row["updated_at"]
│                   )
│                   return ContentItemSuccessResponse(data=created_item)
│           except Exception as e:
│               logger.error(f"Error creating content item: {str(e)}")
│               raise HTTPException(status_code=500, detail="Failed to create content item")
│       # ... (additional endpoints: get, update, delete)
├── embedding.py
│       # db_api/routers/embedding.py
│       import json
│       import logging
│       import torch
│       from fastapi import APIRouter, HTTPException
│       from pydantic import BaseModel, Field
│       from transformers import BertTokenizer, BertModel
│       
│       from db_api.db import get_db
│       from db_api.schemas import Content, ContentItem
│       
│       router = APIRouter(prefix="/embeddings", tags=["Embeddings"])
│       logger = logging.getLogger(__name__)
│       
│       tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
│       model = BertModel.from_pretrained("bert-base-uncased")
│       model.eval()
│       
│       class EmbeddingSentenceRequest(BaseModel):
│           sentence: str = Field(..., min_length=1, max_length=500)
│       # ... (computes BERT embeddings, stores in DB)
└── processor.py
│       # db_api/routers/processor.py
│       from fastapi import APIRouter, HTTPException
│       import json
│       from db_api.db import get_db
│       from db_api.schemas import ProcessedMappingResponse
│       
│       router = APIRouter(prefix="/processor", tags=["Processor"])
│       
│       @router.get("/{content_id}/items/{item_id}/process", response_model=ProcessedMappingResponse)
│       async def process_content_item_metadata(content_id: int, item_id: int):
│           """Process metadata by splitting input text into words."""
│           try:
│               with get_db() as conn:
│                   cursor = conn.execute(
│                       "SELECT metadata FROM content_item WHERE content_id = ? AND id = ?",
│                       (content_id, item_id)
│                   )
│                   row = cursor.fetchone()
│                   if row is None:
│                       raise HTTPException(status_code=404, detail="Content item not found")
│                   metadata = json.loads(row["metadata"])
│                   input_text = metadata.get("input")
│                   words = input_text.split()
│                   processed_mapping = {str(i + 1): word for i, word in enumerate(words)}
│                   return ProcessedMappingResponse(exit_code=0, processed_mapping=processed_mapping)
│           except Exception as e:
│               raise HTTPException(status_code=500, detail=str(e))
```
- Captures `.py` files (flag `-8`) with full content and structure.

#### Examples
##### Next.js Refactor
```sh
ctree -vvv -1 -o app pages > next.ctree
```
- Grabs `.tsx`, `.ts` for AI-driven UI tweaks.

##### FastAPI Backend
```sh
cd db_api/routers/
ctree -vvv -8 > routers.ctree
```
- Targets `.py` files (e.g., `content.py`, `processor.py`) for API updates.

---

## Workflow: Incremental AI Updates

CTree supports manual updates with directory-level commits, scaling from small tweaks to massive refactors (e.g., 0 to 10,000 lines in a day, often reducing lines while preserving functionality). Here’s the process with an AI model (e.g., Anthropic):
1. **Task**: Update a data type (e.g., `str` to `UUID`) in `db_api/routers/content.py`.
2. **Extract**: Run `cd db_api/routers/ && ctree -vvv -8 > routers.ctree`.
3. **Feed AI**: Pass `routers.ctree` to Anthropic, request the change.
4. **Update**: Manually replace modified files (e.g., `content.py`) with the AI’s output.
5. **Repeat**: For other dirs (e.g., `db_api/`), extract, update, replace.
6. **Commit**: Once all dirs are updated, `git commit` entire directories in one pass.

This workflow ensures consistency and scalability across large codebases.

---

## Who’s It For?
- **AI Engineers**: Structure AI inputs for predictable outputs.
- **R&D Devs**: Tame experimental codebases.
- **Teams**: Precision for Next.js, FastAPI, or beyond.
