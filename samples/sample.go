//go:build linux || darwin

// Package sample exercises the token classes the Mapping colours for Go:
// keywords, builtin functions, builtin types, constants, brackets, strings
// with escapes and comments, plus the //go: directives above and below.
package sample

import (
	"errors"
	"fmt"
	"strings"
)

//go:generate stringer -type=State

// State is a small enum; its constants read in the constant colour.
type State int

const (
	Idle State = iota
	Running
	Stopped
)

const MaxRetries = 3

var ErrClosed = errors.New("queue closed")

// Queue holds items; its fields are properties.
type Queue[T any] struct {
	items []T
	limit int
	name  string
}

// Sizer is an interface with one method.
type Sizer interface {
	Size() int
}

// NewQueue builds a Queue over the builtin types string and int.
func NewQueue[T any](name string, limit int) *Queue[T] {
	return &Queue[T]{
		items: make([]T, 0, limit),
		limit: limit,
		name:  name,
	}
}

// Push appends an item unless the queue is full.
func (q *Queue[T]) Push(item T) error {
	if len(q.items) >= q.limit {
		return fmt.Errorf("%s: %w (limit %d)", q.name, ErrClosed, q.limit)
	}
	q.items = append(q.items, item)
	return nil
}

// Size implements Sizer.
func (q *Queue[T]) Size() int { return len(q.items) }

func describe(s State, ratio float64, ok bool) string {
	var sb strings.Builder
	switch s {
	case Idle:
		sb.WriteString("idle\n")
	case Running, Stopped:
		sb.WriteString("busy\t")
	default:
		sb.WriteString(`raw string, no \escapes`)
	}
	if ok && ratio > 0.5 {
		sb.WriteRune('✓')
	}
	return sb.String()
}

func drain(q *Queue[int], out chan<- int) {
	defer close(out)
outer:
	for i, v := range q.items {
		if i >= MaxRetries || v == 0x7f {
			break outer
		}
		out <- v * 2
	}
}

func run() {
	q := NewQueue[int]("jobs", 8)
	_ = q.Push(1)
	out := make(chan int)
	go drain(q, out)
	for v := range out {
		fmt.Println(v, 1e3, 'x', true, out != nil)
	}
}
