# 금융 시스템 연계 아키텍처

## 1. 업무와 통신을 분리합니다

금융 SI에서는 MCA, EAI, FEP, 계정계 및 대외기관 연계가 빈번합니다. 전문 길이, Padding, Encoding, Socket/HTTP 통신을 업무 Service에 직접 넣지 않고 Integration Layer로 분리합니다.

```mermaid
flowchart LR
    BS[Business Service] --> IS[Integration Service]
    IS --> MB[Message Builder]
    MB --> TA[Transport Adapter]
    TA --> EXT[MCA / EAI / FEP]
    EXT --> TA
    TA --> MP[Message Parser]
    MP --> IS
    IS --> BS
```

## 2. 역할

- **Business Service**: 어떤 업무를 요청할지 결정
- **Integration Service**: 연계 흐름과 오류/Timeout 정책 관리
- **Message Builder / Parser**: 전문 정의에 따라 송수신 데이터 변환
- **Transport Adapter**: 실제 통신 방식 캡슐화

## 3. 전체 송수신 시퀀스

```mermaid
sequenceDiagram
    autonumber
    participant B as Business Service
    participant I as Integration Service
    participant M as Builder / Parser
    participant T as Transport Adapter
    participant E as MCA / EAI / FEP
    B->>I: 업무 연계 요청 DTO
    I->>M: 전문 생성
    M-->>I: Outbound Message
    I->>T: Send
    T->>E: 전문 송신
    E-->>T: 응답 전문
    T-->>I: Raw Response
    I->>M: Parsing
    M-->>I: Response DTO
    I-->>B: 업무 응답
```

Trace ID를 연계 로그까지 전달하여 한 요청의 전체 흐름을 추적할 수 있도록 하는 방향을 지향합니다.
